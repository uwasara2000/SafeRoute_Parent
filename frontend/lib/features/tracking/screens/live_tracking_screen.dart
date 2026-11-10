import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/widgets/parent_bottom_navigation.dart';
import '../../children/models/child_model.dart';
import '../../children/services/children_service.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/bus_location.dart';
import '../models/trip_details.dart';
import '../services/bus_tracking_service.dart';
import '../services/tracking_api_service.dart';
import '../services/route_generator_service.dart';
import '../services/trip_id_for_child.dart';
import '../utils/maps_api_status.dart';
import '../../history/screens/journey_history_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final ChildModel? initialChild;
  const LiveTrackingScreen({super.key, this.initialChild});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final BusTrackingService _trackingService = BusTrackingService();
  final TrackingApiService _apiService = TrackingApiService();
  final ChildrenService _childrenService = ChildrenService();

  GoogleMapController? _mapController;
  StreamSubscription<BusLocation?>? _locationSubscription;
  StreamSubscription<bool?>? _tripStatusSubscription;
  StreamSubscription<List<ChildModel>>? _childrenSubscription;

  // Registered Children from Database
  List<ChildModel> _registeredChildren = [];
  ChildModel? _activeChild;

  BusLocation? _latestLocation;
  TripDetails? _tripDetails;
  EtaInfo? _latestEta;
  bool _isTripActive = false;
  bool _isLoadingTrip = true;
  bool _isSavingStops = false;
  bool _autoFollowBus = true; // Automatically tracks bus during ride
  bool _isProgrammaticCameraMove =
      false; // Prevents camera animations from pausing auto-follow
  String? _tripError;
  String? _trackingError;

  // Current pickup & drop-off locations
  BusStop? _currentPickup;
  BusStop? _currentDropOff;
  String _rideStatus = 'Waiting for live bus';

  Marker? _busMarker;
  final Set<Marker> _stopMarkers = {};
  final Set<Polyline> _polylines = {};
  Timer? _statusTicker;
  Timer? _etaTicker;

  // All available Pickup Places across Sri Lanka
  List<BusStop> get _availablePickups => RouteGeneratorService
      .allPickupPlacesInSriLanka
      .map((p) => p.toBusStop(order: 1))
      .toList();

  // All available Schools across Sri Lanka
  List<BusStop> get _availableDropOffs => RouteGeneratorService
      .allSchoolsInSriLanka
      .map((s) => s.toBusStop(order: 99))
      .toList();

  @override
  void initState() {
    super.initState();
    _activeChild = widget.initialChild;

    // 1. Listen to registered children in Firestore database
    _subscribeToChildrenDatabase();

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
    _childrenSubscription = _childrenService.getChildrenStream().listen(
      (children) {
        if (!mounted) return;

        ChildModel? childToBuild;
        setState(() {
          _registeredChildren = children;
          if (children.isEmpty) {
            _activeChild = null;
            _latestLocation = null;
            _busMarker = null;
            _tripDetails = null;
            _isLoadingTrip = false;
            _latestEta = null;
            _tripError = null;
            return;
          }

          final selectedChild = _activeChild;
          childToBuild = selectedChild == null
              ? children.first
              : children.firstWhere(
                  (child) => child.id == selectedChild.id,
                  orElse: () => children.first,
                );
          _activeChild = childToBuild;
          _isLoadingTrip = true;
          _latestLocation = null;
          _busMarker = null;
          _rideStatus = 'Waiting for live bus';
        });

        final child = childToBuild;
        if (child != null) {
          _buildAutoRouteForChild(child);
          _loadTripDetailsAndStops();
          _subscribeToTrip();
        } else {
          _locationSubscription?.cancel();
          _tripStatusSubscription?.cancel();
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _trackingError = 'Unable to load your linked children.';
          _isLoadingTrip = false;
        });
      },
    );
  }

  /// Switch the active child being tracked on the map
  void _selectChild(ChildModel child) {
    setState(() {
      _activeChild = child;
      _rideStatus = 'Waiting for live bus';
      _latestLocation = null;
      _busMarker = null;
      _tripDetails = null;
      _isLoadingTrip = true;
      _tripError = null;
      _trackingError = null;
    });

    _buildAutoRouteForChild(child);

    // Refresh trip & ETA for this child's route
    _loadTripDetailsAndStops();
    _subscribeToTrip();
  }

  /// Automatically generate stops, markers and polyline road route tailored for this child
  Future<void> _buildAutoRouteForChild(ChildModel child) async {
    final pickupPos = RouteGeneratorService.geocodePlace(child.pickupLocation);
    final schoolPos = RouteGeneratorService.geocodePlace(
      child.school,
      isSchool: true,
    );

    await _buildRouteFromPoints(
      pickupPos: pickupPos,
      destinationPos: schoolPos,
      pickupName: child.pickupLocation,
      destinationName: child.school,
      childName: child.name,
      routeName: child.route,
    );
  }

  /// Build markers, polyline and route stops directly from exact coordinates using real road snapping
  Future<void> _buildRouteFromPoints({
    required LatLng pickupPos,
    required LatLng destinationPos,
    required String pickupName,
    required String destinationName,
    String? childName,
    String? routeName,
  }) async {
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

    final cName = childName ?? _activeChild?.name ?? 'Child';
    final rName = routeName ?? _activeChild?.route ?? 'Route';

    // 1. Immediately display pickup & destination markers
    setState(() {
      _stopMarkers.clear();
      _polylines.clear();

      _stopMarkers.add(
        Marker(
          markerId: const MarkerId('stop_pickup'),
          position: pickupPos,
          zIndex: 5,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: '🟢 $cName\'s Pickup',
            snippet: pickupName,
          ),
        ),
      );

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
    });

    _fitCameraToRoute();

    // 2. Fetch real road geometry (hundreds of exact curved street coordinates)
    final roadResult = await RouteGeneratorService.fetchRealRoadRoute(
      pickup: pickupPos,
      destination: destinationPos,
    );

    if (!mounted) return;

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId(
            'real_road_${DateTime.now().millisecondsSinceEpoch}',
          ),
          points: roadResult.points,
          color: const Color(0xFF0D6B5D),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      // 3. Add intermediate waypoints positioned directly along the real road path
      final pts = roadResult.points;
      if (pts.length >= 6) {
        final waypoint1Pos = pts[pts.length ~/ 3];
        final waypoint2Pos = pts[(pts.length * 2) ~/ 3];

        _stopMarkers.removeWhere(
          (m) => m.markerId.value.startsWith('stop_waypoint_'),
        );

        _stopMarkers.add(
          Marker(
            markerId: const MarkerId('stop_waypoint_1'),
            position: waypoint1Pos,
            zIndex: 3,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: 'Transit Waypoint #1',
              snippet: 'En route along $rName',
            ),
          ),
        );

        _stopMarkers.add(
          Marker(
            markerId: const MarkerId('stop_waypoint_2'),
            position: waypoint2Pos,
            zIndex: 3,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: 'Transit Waypoint #2',
              snippet: 'En route along $rName',
            ),
          ),
        );
      }
    });

    _fitCameraToRoute();
  }

  void _fitCameraToRoute() {
    if (_mapController == null ||
        _currentPickup == null ||
        _currentDropOff == null)
      return;

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
    final child = _activeChild;
    if (child == null) {
      if (mounted) setState(() => _isLoadingTrip = false);
      return;
    }

    final tripId = tripIdForChild(child);
    if (tripId == null) {
      if (mounted) {
        setState(() {
          _isLoadingTrip = false;
          _tripError = 'Live tracking is not configured for this route.';
        });
      }
      return;
    }
    try {
      final details = await _apiService.fetchTripDetails(tripId);
      if (!mounted) return;

      setState(() {
        _tripDetails = details;
        _isTripActive = details.active;
        _isLoadingTrip = false;
        _tripError = null;
      });
      await _refreshETA();
    } on TrackingApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _tripDetails = null;
        _isLoadingTrip = false;
        _tripError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tripDetails = null;
        _isLoadingTrip = false;
        _tripError =
            'Unable to load trip details. Check your connection and try again.';
      });
    }
  }

  Future<void> _refreshETA() async {
    if (!_isTripActive || _activeChild == null || _latestLocation == null)
      return;
    final tripId = tripIdForChild(_activeChild);
    if (tripId == null) return;
    try {
      final eta = await _apiService.fetchETA(tripId);
      if (!mounted) return;
      setState(() {
        _latestEta = eta;
        _trackingError = null;
      });
    } on TrackingApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _latestEta = null;
        _trackingError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _latestEta = null;
        _trackingError = 'Unable to refresh the live ETA.';
      });
    }
  }

  void _subscribeToTrip() {
    _locationSubscription?.cancel();
    _tripStatusSubscription?.cancel();
    _locationSubscription = null;
    _tripStatusSubscription = null;

    if (_activeChild == null) return;
    final tripId = tripIdForChild(_activeChild);
    if (tripId == null) {
      setState(
        () =>
            _trackingError = 'Live tracking is not configured for this route.',
      );
      return;
    }

    // 1. Stream real-time coordinates from Firebase Realtime Database
    _locationSubscription = _trackingService
        .watchLocation(tripId)
        .listen(
          (location) {
            if (location != null) {
              _applyLocationUpdate(location);
            }
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(
              () => _trackingError = 'Unable to receive live bus locations.',
            );
          },
        );

    // 2. Stream trip status
    _tripStatusSubscription = _trackingService
        .watchTripStatus(tripId)
        .listen(
          (isActive) {
            if (mounted && isActive != null) {
              setState(() {
                _isTripActive = isActive;
                if (!isActive && _latestLocation != null) {
                  _rideStatus = 'Trip ended';
                }
              });
            }
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(
              () => _trackingError = 'Unable to receive trip status updates.',
            );
          },
        );
  }

  void _applyLocationUpdate(BusLocation location) {
    if (!mounted) return;

    final busLatLng = LatLng(location.latitude, location.longitude);
    final childName = _activeChild?.name.trim();
    final plateNumber = _tripDetails?.vehicle?.plateNumber.trim();

    setState(() {
      _latestLocation = location;
      _rideStatus = _isTripActive ? 'Live' : 'Trip ended';
      _trackingError = null;
      _busMarker = Marker(
        markerId: const MarkerId('school_bus'),
        position: busLatLng,
        rotation: location.heading ?? 0.0,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        zIndex: 10,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: childName?.isNotEmpty == true
              ? '$childName\'s school bus'
              : plateNumber?.isNotEmpty == true
              ? plateNumber!
              : 'School Bus',
          snippet:
              'Speed: ${((location.speedMps ?? 0) * 3.6).toStringAsFixed(0)} km/h • ${_activeChild?.route ?? ""}',
        ),
      );
    });

    // Auto-update camera location during the ride
    if (_autoFollowBus && _mapController != null) {
      _isProgrammaticCameraMove = true;
      _mapController!.animateCamera(CameraUpdate.newLatLng(busLatLng));
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

        final categories =
            ['All'] + items.map((e) => e.category).toSet().toList();

        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            final filtered = items.where((item) {
              final matchesQuery = item.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              final matchesCategory =
                  selectedCategory == 'All' ||
                  item.category == selectedCategory;
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isSchoolPicker
                            ? 'Search any school in Sri Lanka...'
                            : 'Search any town, city, or pickup point...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF0D6B5D),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
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
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF334155),
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
                                  const Icon(
                                    Icons.location_off_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No matching locations for "$searchQuery"',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final customCoords =
                                          RouteGeneratorService.geocodePlace(
                                            searchQuery,
                                            isSchool: isSchoolPicker,
                                          );
                                      final customItem = PlaceItem(
                                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                        name: searchQuery,
                                        category: 'Custom Location',
                                        latitude: customCoords.latitude,
                                        longitude: customCoords.longitude,
                                      );
                                      Navigator.of(ctx).pop(customItem);
                                    },
                                    icon: const Icon(
                                      Icons.add_location_alt,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Use "$searchQuery" as Custom Location',
                                    ),
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
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 64),
                            itemBuilder: (ctx, index) {
                              final item = filtered[index];
                              final isSelected =
                                  item.name.toLowerCase().contains(
                                    currentSelectedName.toLowerCase(),
                                  ) ||
                                  currentSelectedName.toLowerCase().contains(
                                    item.name.toLowerCase(),
                                  );

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSchoolPicker
                                      ? (isSelected
                                            ? const Color(0xFF0D6B5D)
                                            : const Color(0xFFFEE2E2))
                                      : (isSelected
                                            ? const Color(0xFF0D6B5D)
                                            : const Color(0xFFDCFCE7)),
                                  child: Icon(
                                    isSchoolPicker
                                        ? Icons.school
                                        : Icons.location_on,
                                    size: 20,
                                    color: isSelected
                                        ? Colors.white
                                        : (isSchoolPicker
                                              ? Colors.red
                                              : Colors.green),
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF0D6B5D),
                                      )
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
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
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF64748B),
                          ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
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
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF64748B),
                          ),
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
                      onPressed: _isSavingStops
                          ? null
                          : () => _saveLocationChanges(
                              ctx,
                              tempPickup,
                              tempDropOff,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6B5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSavingStops
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Apply Changes to Map & Database',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
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

  Future<void> _saveLocationChanges(
    BuildContext modalContext,
    BusStop pickup,
    BusStop dropOff,
  ) async {
    final child = _activeChild;
    if (child == null) return;

    setState(() {
      _isSavingStops = true;
      _trackingError = null;
    });

    try {
      final tripId = tripIdForChild(child);
      if (tripId == null) {
        throw const TrackingApiException(
          'Live tracking is not configured for this route.',
        );
      }
      await _apiService.updateStops(
        tripId: tripId,
        pickup: {
          'name': pickup.name,
          'latitude': pickup.latitude,
          'longitude': pickup.longitude,
        },
        destination: {
          'name': dropOff.name,
          'latitude': dropOff.latitude,
          'longitude': dropOff.longitude,
        },
      );
      await _childrenService.updateChildLocations(
        childId: child.id,
        pickupLocation: pickup.name,
        dropOffLocation: dropOff.name,
      );

      final updatedChild = ChildModel(
        id: child.id,
        parentId: child.parentId,
        name: child.name,
        school: dropOff.name,
        grade: child.grade,
        route: child.route,
        vehicleNumber: child.vehicleNumber,
        status: child.status,
        eta: child.eta,
        lastKnownLocation: 'Pickup: ${pickup.name} · Drop: ${dropOff.name}',
        schoolInfo: dropOff.name,
        pickupLocation: pickup.name,
        pickupTime: child.pickupTime,
        dropOffLocation: dropOff.name,
        dropOffTime: child.dropOffTime,
        transportOperator: child.transportOperator,
        authorizedGuardians: child.authorizedGuardians,
        emergencyContact: child.emergencyContact,
        initials: child.initials,
      );

      if (!mounted) return;
      setState(() {
        _currentPickup = pickup;
        _currentDropOff = dropOff;
        _activeChild = updatedChild;
      });

      await _buildRouteFromPoints(
        pickupPos: LatLng(pickup.latitude, pickup.longitude),
        destinationPos: LatLng(dropOff.latitude, dropOff.longitude),
        pickupName: pickup.name,
        destinationName: dropOff.name,
        childName: updatedChild.name,
        routeName: updatedChild.route,
      );

      if (modalContext.mounted) Navigator.of(modalContext).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route updated for ${updatedChild.name}.'),
            backgroundColor: const Color(0xFF0D6B5D),
          ),
        );
      }
    } on TrackingApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save the route changes. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingStops = false);
    }
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

  void _navigateToTab(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final child = _activeChild;
    final Widget destination = switch (index) {
      2 => JourneyHistoryScreen(initialChild: child?.name),
      3 => AlertsScreen(initialChild: child),
      4 => const ProfileScreen(),
      _ => const HomeScreen(),
    };
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _tripStatusSubscription?.cancel();
    _childrenSubscription?.cancel();
    _statusTicker?.cancel();
    _etaTicker?.cancel();
    _apiService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _activeChild;
    final driver = _tripDetails?.driver;
    final vehicle = _tripDetails?.vehicle;
    final driverName = driver?.name.trim();
    final childVehicleDetails = child == null
        ? ''
        : [
            child.vehicleNumber.trim(),
            child.transportOperator.trim(),
          ].where((value) => value.isNotEmpty).join(' • ');
    final tripVehicleDetails = vehicle == null
        ? ''
        : [
            vehicle.plateNumber.trim(),
            vehicle.model.trim(),
          ].where((value) => value.isNotEmpty).join(' • ');
    final vehicleDetails = childVehicleDetails.isNotEmpty
        ? childVehicleDetails
        : tripVehicleDetails.isNotEmpty
        ? tripVehicleDetails
        : 'Vehicle details unavailable';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              child != null ? 'Track ${child.name}' : 'Track School Bus',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              child != null
                  ? '${child.school} • ${child.route}'
                  : (_tripDetails?.routeName ?? 'School Route'),
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
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
          if (isGoogleMapsApiAvailable)
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
            )
          else
            const ColoredBox(
              color: Color(0xFFF1F5F9),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Google Maps is not configured for Web. Set a valid key in '
                    'web/maps_config.js and restart the app.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          if (_registeredChildren.isEmpty || _tripError != null)
            Positioned(
              top: 72,
              left: 18,
              right: 18,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF0D6B5D)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _registeredChildren.isEmpty
                              ? 'Link a child from your dashboard to start tracking.'
                              : _tripError!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (_tripError != null)
                        IconButton(
                          tooltip: 'Retry',
                          onPressed: _isLoadingTrip
                              ? null
                              : _loadTripDetailsAndStops,
                          icon: const Icon(Icons.refresh),
                        ),
                    ],
                  ),
                ),
              ),
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
                        final isSelected =
                            c.id == _activeChild?.id ||
                            c.name == _activeChild?.name;
                        return ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.white
                                : const Color(0xFF0D6B5D),
                            child: Text(
                              c.initials,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF0D6B5D)
                                    : Colors.white,
                              ),
                            ),
                          ),
                          label: Text(
                            '${c.name} (${c.school.split(' ').first})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
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
                      onPressed: child == null
                          ? null
                          : _openChangeLocationsSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D6B5D),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit_location_alt,
                        size: 18,
                        color: Color(0xFF0D6B5D),
                      ),
                      label: const Text(
                        'Change Places',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _latestLocation == null
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFE2F4F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _latestLocation == null
                                    ? Icons.gps_not_fixed
                                    : Icons.gps_fixed,
                                size: 14,
                                color: _latestLocation == null
                                    ? Colors.orange
                                    : const Color(0xFF0D6B5D),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _latestLocation == null
                                    ? 'Waiting for GPS'
                                    : 'Live GPS',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D6B5D),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Auto-Tracking Toggle Pill
                        InkWell(
                          onTap: () {
                            setState(() {
                              _autoFollowBus = !_autoFollowBus;
                              if (_autoFollowBus) _recenterOnBus();
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _autoFollowBus
                                      ? Icons.sync
                                      : Icons.sync_disabled,
                                  size: 14,
                                  color: _autoFollowBus
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _autoFollowBus
                                      ? 'Auto-Follow'
                                      : 'Free Explore',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _autoFollowBus
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                  backgroundColor: _autoFollowBus
                      ? const Color(0xFF0D6B5D)
                      : Colors.white,
                  onPressed: _recenterOnBus,
                  child: Icon(
                    Icons.my_location,
                    color: _autoFollowBus
                        ? Colors.white
                        : const Color(0xFF0D6B5D),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  backgroundColor: Colors.white,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  backgroundColor: Colors.white,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomOut()),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
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
                                _rideStatus,
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
                            const Icon(
                              Icons.access_time_filled,
                              size: 16,
                              color: Color(0xFF0D6B5D),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _latestEta != null
                                  ? '${_latestEta!.isEstimate ? 'Estimated arrival' : 'Arriving'} in ${_latestEta!.etaMinutes} min • ${_latestEta!.distanceKm} km'
                                  : _latestLocation == null
                                  ? (_isLoadingTrip
                                        ? 'Loading trip details…'
                                        : 'Waiting for live bus location')
                                  : 'Calculating live ETA…',
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

                    if (_trackingError != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _trackingError!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Pickup and Drop-off summary strip for this child
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trip_origin,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _currentPickup?.name ??
                                  (child?.pickupLocation ?? 'Pickup'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _currentDropOff?.name ??
                                  (child?.school ?? 'School'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
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
                          child: Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName?.isNotEmpty == true
                                    ? '$driverName (Driver)'
                                    : 'Driver details unavailable',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicleDetails,
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
                          icon: const Icon(
                            Icons.copy,
                            color: Color(0xFF0D6B5D),
                            size: 20,
                          ),
                          tooltip: 'Copy driver phone number',
                          onPressed: driver?.phone.isNotEmpty == true
                              ? () {
                                  final phone = driver!.phone;
                                  Clipboard.setData(ClipboardData(text: phone));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Driver phone number copied: $phone',
                                      ),
                                      backgroundColor: const Color(0xFF0D6B5D),
                                    ),
                                  );
                                }
                              : null,
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => JourneyHistoryScreen(
                                initialChild: child?.name,
                              ),
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
      bottomNavigationBar: ParentBottomNavigation(
        currentIndex: 1,
        onTap: _navigateToTab,
      ),
    );
  }
}
