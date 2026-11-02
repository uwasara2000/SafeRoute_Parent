import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../children/models/child_model.dart';
import '../../children/services/children_service.dart';
import '../models/bus_location.dart';
import '../models/trip_details.dart';
import '../services/bus_tracking_service.dart';
import '../services/tracking_api_service.dart';
import '../services/route_generator_service.dart';
import '../../history/screens/journey_history_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final ChildModel? initialChild;
  final String tripId;

  const LiveTrackingScreen({
    super.key,
    this.initialChild,
    this.tripId = 'trip_001',
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final BusTrackingService _trackingService = BusTrackingService();
  final TrackingApiService _apiService = TrackingApiService();
  final ChildrenService _childrenService = ChildrenService();

  GoogleMapController? _mapController;
  StreamSubscription<BusLocation?>? _locationSubscription;
  StreamSubscription<bool>? _tripStatusSubscription;
  StreamSubscription<List<ChildModel>>? _childrenSubscription;

  // Registered Children from Database
  List<ChildModel> _registeredChildren = [];
  ChildModel? _activeChild;

  BusLocation? _latestLocation;
  TripDetails? _tripDetails;
  EtaInfo? _latestEta;
  bool _isTripActive = true;
  bool _isLoadingTrip = true;
  bool _autoFollowBus = true; // Automatically tracks bus during ride
  bool _isProgrammaticCameraMove = false; // Prevents camera animations from pausing auto-follow

  // Current pickup & drop-off locations
  BusStop? _currentPickup;
  BusStop? _currentDropOff;
  String _rideStatus = 'ON BOARD';

  Marker? _busMarker;
  final Set<Marker> _stopMarkers = {};
  final Set<Polyline> _polylines = {};
  Timer? _statusTicker;
  Timer? _etaTicker;

  // All available Pickup Places across Sri Lanka
  List<BusStop> get _availablePickups => RouteGeneratorService.allPickupPlacesInSriLanka
      .map((p) => p.toBusStop(order: 1))
      .toList();

  // All available Schools across Sri Lanka
  List<BusStop> get _availableDropOffs => RouteGeneratorService.allSchoolsInSriLanka
      .map((s) => s.toBusStop(order: 99))
      .toList();

  @override
  void initState() {
    super.initState();
    _activeChild = widget.initialChild;

    // 1. Listen to registered children in Firestore database
    _subscribeToChildrenDatabase();

    // 2. Fetch trip info & driver data
    _loadTripDetailsAndStops();

    // 3. Listen to live GPS stream
    _subscribeToTrip();

    // Re-render every 3 seconds to update freshness label
    _statusTicker = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() {});
    });

    // Refresh ETA every 15 seconds
    _etaTicker = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshETA();
    });
  }

  void _subscribeToChildrenDatabase() {
    _childrenSubscription = _childrenService.getChildrenStream().listen((children) {
      if (!mounted) return;

      setState(() {
        if (children.isNotEmpty) {
          _registeredChildren = children;
        } else {
          // Fallback to two demo children so the screen is always fully functional
          _registeredChildren = [
            ChildModel.defaultAmaya('demo'),
            ChildModel.defaultSecondChild('demo'),
          ];
        }

        // If no active child was chosen or active child is not in the list, set first
        if (_activeChild == null) {
          _activeChild = _registeredChildren.first;
          _buildAutoRouteForChild(_activeChild!);
        } else {
          // Re-sync with latest data from Firestore if active child was updated
          final match = _registeredChildren.firstWhere(
            (c) => c.id == _activeChild!.id || c.name == _activeChild!.name,
            orElse: () => _activeChild!,
          );
          _activeChild = match;
          _buildAutoRouteForChild(_activeChild!);
        }
      });
    });
  }

  /// Switch the active child being tracked on the map
  void _selectChild(ChildModel child) {
    setState(() {
      _activeChild = child;
      _rideStatus = child.status;
      _buildAutoRouteForChild(child);
    });

    // Fit camera to the newly selected child's route
    _fitCameraToRoute();

    // Refresh trip & ETA for this child's route
    _loadTripDetailsAndStops();
    _subscribeToTrip();
  }

  String _getChildTripId() {
    if (_activeChild == null) return widget.tripId;
    final r = _activeChild!.route.toLowerCase();
    if (r.contains('08')) return 'route_08';
    if (r.contains('14')) return 'route_14';
    if (r.contains('12')) return 'trip_001';
    return widget.tripId;
  }

  /// Automatically generate stops, markers and polyline road route tailored for this child
  void _buildAutoRouteForChild(ChildModel child) {
    final pickupPos = RouteGeneratorService.geocodePlace(child.pickupLocation);
    final schoolPos = RouteGeneratorService.geocodePlace(child.school, isSchool: true);

    _buildRouteFromPoints(
      pickupPos: pickupPos,
      destinationPos: schoolPos,
      pickupName: child.pickupLocation,
      destinationName: child.school,
      childName: child.name,
      routeName: child.route,
    );
  }

  /// Build markers, polyline and route stops directly from exact coordinates
  void _buildRouteFromPoints({
    required LatLng pickupPos,
    required LatLng destinationPos,
    required String pickupName,
    required String destinationName,
    String? childName,
    String? routeName,
  }) {
    _currentPickup = BusStop(
      id: 'pickup_${DateTime.now().millisecondsSinceEpoch}',
      name: pickupName,
      latitude: pickupPos.latitude,
      longitude: pickupPos.longitude,
      order: 1,
    );

    _currentDropOff = BusStop(
      id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
      name: destinationName,
      latitude: destinationPos.latitude,
      longitude: destinationPos.longitude,
      order: 99,
    );

    _stopMarkers.clear();
    _polylines.clear();

    final cName = childName ?? _activeChild?.name ?? 'Child';
    final rName = routeName ?? _activeChild?.route ?? 'Route';

    // 1. Add 🟢 Green Pickup Marker
    _stopMarkers.add(
      Marker(
        markerId: const MarkerId('stop_pickup'),
        position: pickupPos,
        zIndex: 5,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '🟢 $cName\'s Pickup',
          snippet: pickupName,
        ),
      ),
    );

    // 2. Add 🏫 Red School Destination Marker
    _stopMarkers.add(
      Marker(
        markerId: const MarkerId('stop_destination'),
        position: destinationPos,
        zIndex: 5,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: '🏫 $cName\'s School',
          snippet: destinationName,
        ),
      ),
    );

    // 3. Generate Auto-Route curved street polyline
    final routePoints = RouteGeneratorService.generateAutoRoute(
      pickup: pickupPos,
      destination: destinationPos,
    );

    // 4. Add intermediate waypoints for context
    final intermediateStops = RouteGeneratorService.generateIntermediateStops(
      pickup: pickupPos,
      destination: destinationPos,
      pickupName: pickupName,
      schoolName: destinationName,
    );

    for (int i = 1; i < intermediateStops.length - 1; i++) {
      final stop = intermediateStops[i];
      _stopMarkers.add(
        Marker(
          markerId: MarkerId('stop_waypoint_$i'),
          position: LatLng(stop.latitude, stop.longitude),
          zIndex: 3,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Waypoint #$i along $rName',
          ),
        ),
      );
    }

    _polylines.add(
      Polyline(
        polylineId: PolylineId('auto_route_${DateTime.now().millisecondsSinceEpoch}'),
        points: routePoints,
        color: const Color(0xFF0D6B5D),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
  }

  void _fitCameraToRoute() {
    if (_mapController == null || _currentPickup == null || _currentDropOff == null) return;

    final pLat = _currentPickup!.latitude;
    final pLng = _currentPickup!.longitude;
    final dLat = _currentDropOff!.latitude;
    final dLng = _currentDropOff!.longitude;

    final south = pLat < dLat ? pLat : dLat;
    final north = pLat > dLat ? pLat : dLat;
    final west = pLng < dLng ? pLng : dLng;
    final east = pLng > dLng ? pLng : dLng;

    final latPad = (north - south) < 0.02 ? 0.02 : (north - south) * 0.18;
    final lngPad = (east - west) < 0.02 ? 0.02 : (east - west) * 0.18;

    _isProgrammaticCameraMove = true;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south - latPad, west - lngPad),
          northeast: LatLng(north + latPad, east + lngPad),
        ),
        50,
      ),
    );
  }

  Future<void> _loadTripDetailsAndStops() async {
    final tripId = _getChildTripId();
    final details = await _apiService.fetchTripDetails(tripId);
    if (!mounted) return;

    setState(() {
      _tripDetails = details;
      _isLoadingTrip = false;
      if (details != null) {
        _isTripActive = details.active;
      }
    });

    _refreshETA();
  }

  Future<void> _refreshETA() async {
    if (!_isTripActive) return;
    final tripId = _getChildTripId();
    final eta = await _apiService.fetchETA(tripId);
    if (mounted && eta != null) {
      setState(() {
        _latestEta = eta;
      });
    }
  }

  void _subscribeToTrip() {
    _locationSubscription?.cancel();
    _tripStatusSubscription?.cancel();

    final tripId = _getChildTripId();

    // 1. Stream real-time coordinates from Firebase Realtime Database
    _locationSubscription = _trackingService
        .watchLocation(tripId)
        .listen((location) {
      if (location != null) {
        _applyLocationUpdate(location);
      }
    });

    // 2. Stream trip status
    _tripStatusSubscription = _trackingService
        .watchTripStatus(tripId)
        .listen((isActive) {
      if (mounted) {
        setState(() {
          _isTripActive = isActive;
        });
      }
    });
  }

  void _applyLocationUpdate(BusLocation location) {
    if (!mounted) return;

    final busLatLng = LatLng(location.latitude, location.longitude);

    setState(() {
      _latestLocation = location;
      _busMarker = Marker(
        markerId: const MarkerId('school_bus'),
        position: busLatLng,
        rotation: location.heading ?? 0.0,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        zIndex: 10,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: _activeChild != null
              ? '${_activeChild!.name}\'s Bus (${_activeChild!.vehicleNumber})'
              : (_tripDetails?.vehicle.plateNumber ?? 'School Bus'),
          snippet: 'Speed: ${((location.speedMps ?? 0) * 3.6).toStringAsFixed(0)} km/h • ${_activeChild?.route ?? ""}',
        ),
      );
    });

    // Auto-update camera location during the ride
    if (_autoFollowBus && _mapController != null) {
      _isProgrammaticCameraMove = true;
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(busLatLng),
      );
    }
  }

  void _recenterOnBus() {
    setState(() {
      _autoFollowBus = true; // Re-enable auto tracking
    });

    if (_mapController != null) {
      _isProgrammaticCameraMove = true;
      if (_latestLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_latestLocation!.latitude, _latestLocation!.longitude),
            15.5,
          ),
        );
      } else if (_currentPickup != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPickup!.latitude, _currentPickup!.longitude),
            14.5,
          ),
        );
      }
    }
  }

  /// Open searchable modal bottom sheet with ALL places or ALL schools in Sri Lanka
  Future<PlaceItem?> _openPlaceSearchPicker({
    required BuildContext context,
    required String title,
    required bool isSchoolPicker,
    required String currentSelectedName,
  }) async {
    final List<PlaceItem> items = isSchoolPicker
        ? RouteGeneratorService.allSchoolsInSriLanka
        : RouteGeneratorService.allPickupPlacesInSriLanka;

    return showModalBottomSheet<PlaceItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (pickerContext) {
        String searchQuery = '';
        String selectedCategory = 'All';

        final categories = ['All'] + items.map((e) => e.category).toSet().toList();

        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            final filtered = items.where((item) {
              final matchesQuery = item.name.toLowerCase().contains(searchQuery.toLowerCase());
              final matchesCategory = selectedCategory == 'All' || item.category == selectedCategory;
              return matchesQuery && matchesCategory;
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isSchoolPicker
                            ? 'Search any school in Sri Lanka...'
                            : 'Search any town, city, or pickup point...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0D6B5D)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setPickerState(() {
                          searchQuery = val.trim();
                        });
                      },
                    ),
                  ),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: categories.map((cat) {
                        final isSel = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                            selected: isSel,
                            selectedColor: const Color(0xFF0D6B5D),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (_) {
                              setPickerState(() {
                                selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(height: 16),

                  // List of Places / Schools
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No matching locations for "$searchQuery"',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final customCoords = RouteGeneratorService.geocodePlace(searchQuery, isSchool: isSchoolPicker);
                                      final customItem = PlaceItem(
                                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                        name: searchQuery,
                                        category: 'Custom Location',
                                        latitude: customCoords.latitude,
                                        longitude: customCoords.longitude,
                                      );
                                      Navigator.of(ctx).pop(customItem);
                                    },
                                    icon: const Icon(Icons.add_location_alt, size: 18),
                                    label: Text('Use "$searchQuery" as Custom Location'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D6B5D),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                            itemBuilder: (ctx, index) {
                              final item = filtered[index];
                              final isSelected = item.name.toLowerCase().contains(currentSelectedName.toLowerCase()) ||
                                                 currentSelectedName.toLowerCase().contains(item.name.toLowerCase());

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSchoolPicker
                                      ? (isSelected ? const Color(0xFF0D6B5D) : const Color(0xFFFEE2E2))
                                      : (isSelected ? const Color(0xFF0D6B5D) : const Color(0xFFDCFCE7)),
                                  child: Icon(
                                    isSchoolPicker ? Icons.school : Icons.location_on,
                                    size: 20,
                                    color: isSelected
                                        ? Colors.white
                                        : (isSchoolPicker ? Colors.red : Colors.green),
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF0D6B5D))
                                    : null,
                                onTap: () {
                                  Navigator.of(ctx).pop(item);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Open bottom sheet to change Pickup & Drop-Off locations and sync with Database
  void _openChangeLocationsSheet() {
    BusStop tempPickup = _currentPickup ?? _availablePickups.first;
    BusStop tempDropOff = _currentDropOff ?? _availableDropOffs.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _activeChild != null
                            ? 'Change Places for ${_activeChild!.name}'
                            : 'Change Route Places',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select a new pickup point or school drop-off to automatically recalculate the map path, markers and arrival time.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // 1. Pickup Place Selection Box (Tap to search & select from all Sri Lanka places)
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Child Pickup Place',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selected = await _openPlaceSearchPicker(
                        context: modalContext,
                        title: 'All Pickup Places in Sri Lanka',
                        isSchoolPicker: false,
                        currentSelectedName: tempPickup.name,
                      );
                      if (selected != null) {
                        setModalState(() {
                          tempPickup = selected.toBusStop(order: 1);
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tempPickup.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. School / Drop-off Place Selection Box (Tap to search & select from all Sri Lanka schools)
                  const Row(
                    children: [
                      Icon(Icons.flag_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'School / Drop-off Place',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selected = await _openPlaceSearchPicker(
                        context: modalContext,
                        title: 'All Schools in Sri Lanka',
                        isSchoolPicker: true,
                        currentSelectedName: tempDropOff.name,
                      );
                      if (selected != null) {
                        setModalState(() {
                          tempDropOff = selected.toBusStop(order: 99);
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tempDropOff.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();

                        // 1. Get exact coordinates directly from the selected objects
                        final pickupPos = LatLng(tempPickup.latitude, tempPickup.longitude);
                        final dropOffPos = LatLng(tempDropOff.latitude, tempDropOff.longitude);

                        // 2. Build the route immediately using these exact coordinates
                        setState(() {
                          _currentPickup = tempPickup;
                          _currentDropOff = tempDropOff;
                          _buildRouteFromPoints(
                            pickupPos: pickupPos,
                            destinationPos: dropOffPos,
                            pickupName: tempPickup.name,
                            destinationName: tempDropOff.name,
                          );

                          if (_activeChild != null) {
                            _activeChild = ChildModel(
                              id: _activeChild!.id,
                              parentId: _activeChild!.parentId,
                              name: _activeChild!.name,
                              school: tempDropOff.name,
                              grade: _activeChild!.grade,
                              route: _activeChild!.route,
                              vehicleNumber: _activeChild!.vehicleNumber,
                              status: _activeChild!.status,
                              eta: _activeChild!.eta,
                              lastKnownLocation: 'Pickup: ${tempPickup.name} · Drop: ${tempDropOff.name}',
                              schoolInfo: '${tempDropOff.name}, Colombo',
                              pickupLocation: tempPickup.name,
                              pickupTime: _activeChild!.pickupTime,
                              dropOffLocation: tempDropOff.name,
                              dropOffTime: _activeChild!.dropOffTime,
                              transportOperator: _activeChild!.transportOperator,
                              authorizedGuardians: _activeChild!.authorizedGuardians,
                              emergencyContact: _activeChild!.emergencyContact,
                              initials: _activeChild!.initials,
                            );
                          }
                        });

                        // 3. Immediately animate and fit camera to the new route
                        _fitCameraToRoute();

                        // 4. Persist to Cloud Firestore Database!
                        if (_activeChild != null && _activeChild!.id.isNotEmpty) {
                          await _childrenService.updateChildLocations(
                            childId: _activeChild!.id,
                            pickupLocation: tempPickup.name,
                            dropOffLocation: tempDropOff.name,
                          );
                        }

                        // 5. Notify backend API
                        await _apiService.updateStops(
                          tripId: _getChildTripId(),
                          pickup: {
                            'name': tempPickup.name,
                            'latitude': tempPickup.latitude,
                            'longitude': tempPickup.longitude,
                          },
                          destination: {
                            'name': tempDropOff.name,
                            'latitude': tempDropOff.latitude,
                            'longitude': tempDropOff.longitude,
                          },
                        );

                        // 6. Refresh ETA
                        _refreshETA();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📍 Route updated for ${_activeChild?.name ?? "Child"}: ${tempPickup.name} ➔ ${tempDropOff.name}'),
                              backgroundColor: const Color(0xFF0D6B5D),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6B5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Changes to Map & Database',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTimeAgoString() {
    if (_latestLocation == null) return 'Waiting for GPS...';
    final difference = DateTime.now().difference(_latestLocation!.updatedAt);
    if (difference.inSeconds < 10) {
      return 'Live • just now';
    } else if (difference.inMinutes < 1) {
      return 'Updated ${difference.inSeconds}s ago';
    } else {
      return 'Delayed • ${difference.inMinutes}m ago';
    }
  }

  Color _getStatusColor() {
    if (!_isTripActive) return Colors.grey;
    if (_latestLocation == null) return Colors.orange;
    final diff = DateTime.now().difference(_latestLocation!.updatedAt);
    if (diff.inSeconds <= 15) return const Color(0xFF22C55E);
    if (diff.inMinutes <= 2) return Colors.orange;
    return Colors.red;
  }

  Set<Marker> _getAllMarkers() {
    final markers = Set<Marker>.from(_stopMarkers);
    if (_busMarker != null) {
      markers.add(_busMarker!);
    }
    return markers;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _tripStatusSubscription?.cancel();
    _childrenSubscription?.cancel();
    _statusTicker?.cancel();
    _etaTicker?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _activeChild;
    final driver = _tripDetails?.driver;
    final vehicle = _tripDetails?.vehicle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              child != null ? 'Track ${child.name}' : 'Track School Bus',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A)),
            ),
            Text(
              child != null ? '${child.school} • ${child.route}' : (_tripDetails?.routeName ?? 'School Route'),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Chip(
              avatar: CircleAvatar(
                radius: 4,
                backgroundColor: _getStatusColor(),
              ),
              label: Text(
                _isTripActive ? _getTimeAgoString() : 'Trip Ended',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFFF1F5F9),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map with Bus, Stops, and Polyline
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.9044, 79.8622),
              zoom: 13.5,
            ),
            markers: _getAllMarkers(),
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onCameraMoveStarted: () {
              if (_isProgrammaticCameraMove) return;
              if (_autoFollowBus) {
                setState(() {
                  _autoFollowBus = false;
                });
              }
            },
            onCameraIdle: () {
              _isProgrammaticCameraMove = false;
            },
            onMapCreated: (controller) {
              _mapController = controller;
              if (_activeChild != null) {
                _fitCameraToRoute();
              } else if (_latestLocation != null) {
                _recenterOnBus();
              }
            },
          ),

          // Top Child Switcher & Action Controls
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal child selector chips (from Database)
                if (_registeredChildren.length > 1)
                  Container(
                    height: 38,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _registeredChildren.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final c = _registeredChildren[index];
                        final isSelected = c.id == _activeChild?.id || c.name == _activeChild?.name;
                        return ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: isSelected ? Colors.white : const Color(0xFF0D6B5D),
                            child: Text(
                              c.initials,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFF0D6B5D) : Colors.white,
                              ),
                            ),
                          ),
                          label: Text(
                            '${c.name} (${c.school.split(' ').first})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0D6B5D),
                          backgroundColor: Colors.white.withOpacity(0.95),
                          elevation: 3,
                          onSelected: (_) => _selectChild(c),
                        );
                      },
                    ),
                  ),

                // Change Places & Auto-Tracking pill row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openChangeLocationsSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D6B5D),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.edit_location_alt, size: 18, color: Color(0xFF0D6B5D)),
                      label: const Text(
                        'Change Places',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _autoFollowBus ? Icons.sync : Icons.sync_disabled,
                            size: 14,
                            color: _autoFollowBus ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _autoFollowBus ? 'Auto-Tracking' : 'Free Explore',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _autoFollowBus ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map Control Buttons (Recenter, Zoom In/Out)
          Positioned(
            right: 16,
            bottom: 275,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: _autoFollowBus ? const Color(0xFF0D6B5D) : Colors.white,
                  onPressed: _recenterOnBus,
                  child: Icon(
                    Icons.my_location,
                    color: _autoFollowBus ? Colors.white : const Color(0xFF0D6B5D),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  backgroundColor: Colors.white,
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  backgroundColor: Colors.white,
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Bottom Sheet with Child, ETA, Pickup/Drop-off & Driver Info
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status & ETA Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F4F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D6B5D),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                child?.status ?? _rideStatus,
                                style: const TextStyle(
                                  color: Color(0xFF0D6B5D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Real-time calculated ETA
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF0D6B5D)),
                            const SizedBox(width: 5),
                            Text(
                              _latestEta != null
                                  ? 'Arriving in ${_latestEta!.etaMinutes} min • ${_latestEta!.distanceKm} km'
                                  : (child?.eta ?? 'Calculating ETA...'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Pickup and Drop-off summary strip for this child
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trip_origin, size: 14, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _currentPickup?.name ?? (child?.pickupLocation ?? 'Pickup'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward, size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          const Icon(Icons.location_on, size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _currentDropOff?.name ?? (child?.school ?? 'School'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Driver & Vehicle Details (Matched to child's route and vehicle)
                    Row(
                      children: [
                        const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFFFB703),
                            child: Icon(Icons.directions_bus_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver != null ? '${driver.name} (Driver)' : 'Sunil Weerasinghe (Driver)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                child != null
                                    ? '${child.vehicleNumber} • ${child.transportOperator}'
                                    : (vehicle != null
                                        ? '${vehicle.plateNumber} • ${vehicle.model}'
                                        : 'NB-4821 • City School Transport'),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFE2F4F0),
                          ),
                          icon: const Icon(Icons.phone, color: Color(0xFF0D6B5D), size: 20),
                          onPressed: () {
                            final phone = driver?.phone ?? child?.emergencyContact ?? '+94 77 555 0199';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling driver: $phone'),
                                backgroundColor: const Color(0xFF0D6B5D),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Navigation to Journey History
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D6B5D),
                          side: const BorderSide(color: Color(0xFFD1E5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text(
                          'View Full Journey Timeline',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const JourneyHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
