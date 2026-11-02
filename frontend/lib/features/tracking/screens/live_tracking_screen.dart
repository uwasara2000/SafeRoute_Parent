import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_location.dart';
import '../models/trip_details.dart';
import '../services/bus_tracking_service.dart';
import '../services/tracking_api_service.dart';
import '../../history/screens/journey_history_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String tripId;

  const LiveTrackingScreen({
    super.key,
    this.tripId = 'trip_001',
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final BusTrackingService _trackingService = BusTrackingService();
  final TrackingApiService _apiService = TrackingApiService();

  GoogleMapController? _mapController;
  StreamSubscription<BusLocation?>? _locationSubscription;
  StreamSubscription<bool>? _tripStatusSubscription;

  BusLocation? _latestLocation;
  TripDetails? _tripDetails;
  EtaInfo? _latestEta;
  bool _isTripActive = true;
  bool _isLoadingTrip = true;
  bool _autoFollowBus = true; // Automatically tracks bus during ride
  bool _isProgrammaticCameraMove = false; // Prevents programmatic camera moves from disabling auto-follow

  // Current pickup & drop-off locations
  BusStop? _currentPickup;
  BusStop? _currentDropOff;
  String _rideStatus = 'ON BOARD'; // 'WAITING FOR BUS', 'ON BOARD', 'ARRIVED'

  Marker? _busMarker;
  final Set<Marker> _stopMarkers = {};
  final Set<Polyline> _polylines = {};
  Timer? _statusTicker;
  Timer? _etaTicker;

  // Default initial camera position (Colombo area)
  static const LatLng _initialPosition = LatLng(6.9271, 79.8612);

  // Available Pickup Places for Parents to select
  final List<BusStop> _availablePickups = const [
    BusStop(id: 'pickup_wattala', name: 'Wattala Junction (Main Road)', latitude: 6.9890, longitude: 79.8910, order: 1),
    BusStop(id: 'pickup_negombo', name: 'Negombo Road / Mabole', latitude: 6.9810, longitude: 79.8930, order: 1),
    BusStop(id: 'pickup_peliyagoda', name: 'Peliyagoda Interchange', latitude: 6.9650, longitude: 79.9050, order: 1),
    BusStop(id: 'pickup_kelaniya', name: 'Kelaniya Temple Road', latitude: 6.9530, longitude: 79.9160, order: 1),
    BusStop(id: 'pickup_kiribathgoda', name: 'Kiribathgoda Town Stop', latitude: 6.9790, longitude: 79.9280, order: 1),
    BusStop(id: 'pickup_kadawatha', name: 'Kadawatha Bus Stand', latitude: 7.0010, longitude: 79.9520, order: 1),
  ];

  // Available Drop-off / Destination Places
  final List<BusStop> _availableDropOffs = const [
    BusStop(id: 'dest_gateway_main', name: 'Gateway College (Main Gate)', latitude: 6.9080, longitude: 79.8970, order: 99),
    BusStop(id: 'dest_gateway_junior', name: 'Gateway Junior School Gate', latitude: 6.9095, longitude: 79.8950, order: 99),
    BusStop(id: 'dest_borella', name: 'Borella Junction Stop', latitude: 6.9140, longitude: 79.8770, order: 99),
    BusStop(id: 'dest_rajagiriya', name: 'Rajagiriya Afterschool Care', latitude: 6.9110, longitude: 79.8890, order: 99),
    BusStop(id: 'dest_royal_college', name: 'Royal College Sports Complex', latitude: 6.9040, longitude: 79.8620, order: 99),
    BusStop(id: 'dest_colombo_library', name: 'Public Library Colombo 07', latitude: 6.9130, longitude: 79.8600, order: 99),
  ];

  @override
  void initState() {
    super.initState();
    _loadTripDetailsAndStops();
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

  Future<void> _loadTripDetailsAndStops() async {
    final details = await _apiService.fetchTripDetails(widget.tripId);
    if (!mounted) return;

    setState(() {
      _tripDetails = details;
      _isLoadingTrip = false;
      if (details != null) {
        _isTripActive = details.active;
        _currentPickup = details.stops.isNotEmpty ? details.stops.first : _availablePickups.first;
        _currentDropOff = details.destination;
        _buildStopsAndRoute();
      }
    });

    _refreshETA();
  }

  void _buildStopsAndRoute() {
    _stopMarkers.clear();
    _polylines.clear();

    final List<LatLng> routePoints = [];

    // 1. Add Pickup Marker (🟢 Green)
    if (_currentPickup != null) {
      final pickupPos = LatLng(_currentPickup!.latitude, _currentPickup!.longitude);
      routePoints.add(pickupPos);
      _stopMarkers.add(
        Marker(
          markerId: const MarkerId('stop_pickup'),
          position: pickupPos,
          zIndex: 5,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '🟢 Pickup: ${_currentPickup!.name}',
            snippet: 'Child Boarding Point',
          ),
        ),
      );
    }

    // 2. Add intermediate route waypoints if available
    if (_tripDetails != null) {
      for (final stop in _tripDetails!.stops) {
        if (stop.id != _currentPickup?.id && stop.id != _currentDropOff?.id) {
          final pos = LatLng(stop.latitude, stop.longitude);
          routePoints.add(pos);
          _stopMarkers.add(
            Marker(
              markerId: MarkerId('stop_${stop.id}'),
              position: pos,
              zIndex: 3,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(
                title: stop.name,
                snippet: 'Stop #${stop.order}',
              ),
            ),
          );
        }
      }
    }

    // 3. Add Drop-off / Destination Marker (🔴 Red)
    if (_currentDropOff != null) {
      final dropOffPos = LatLng(_currentDropOff!.latitude, _currentDropOff!.longitude);
      routePoints.add(dropOffPos);
      _stopMarkers.add(
        Marker(
          markerId: const MarkerId('stop_destination'),
          position: dropOffPos,
          zIndex: 5,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '🏫 Drop-off: ${_currentDropOff!.name}',
            snippet: 'Destination Stop',
          ),
        ),
      );
    }

    // 4. Draw continuous polyline connecting pickup -> waypoints -> drop-off
    if (routePoints.length >= 2) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('bus_route_line'),
          points: routePoints,
          color: const Color(0xFF0D6B5D),
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }
  }

  Future<void> _refreshETA() async {
    if (!_isTripActive) return;
    final eta = await _apiService.fetchETA(widget.tripId);
    if (mounted && eta != null) {
      setState(() {
        _latestEta = eta;
      });
    }
  }

  void _subscribeToTrip() {
    _locationSubscription = _trackingService
        .watchLocation(widget.tripId)
        .listen((location) {
      if (location != null) {
        _applyLocationUpdate(location);
      }
    });

    _tripStatusSubscription = _trackingService
        .watchTripStatus(widget.tripId)
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
          title: _tripDetails?.vehicle.plateNumber ?? 'School Bus',
          snippet: 'Speed: ${((location.speedMps ?? 0) * 3.6).toStringAsFixed(0)} km/h',
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

  /// Open bottom sheet to change Pickup & Drop-Off locations
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
                      const Text(
                        'Change Route Places',
                        style: TextStyle(
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
                    'Update pickup & drop-off to automatically adjust the map path and arrival time.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // 1. Pickup Place Selection
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BusStop>(
                        isExpanded: true,
                        value: _availablePickups.firstWhere(
                          (p) => p.id == tempPickup.id,
                          orElse: () => _availablePickups.first,
                        ),
                        items: _availablePickups.map((stop) {
                          return DropdownMenuItem<BusStop>(
                            value: stop,
                            child: Text(
                              stop.name,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStop) {
                          if (newStop != null) {
                            setModalState(() {
                              tempPickup = newStop;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Drop-off Place Selection
                  const Row(
                    children: [
                      Icon(Icons.flag_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Child Drop-off Place',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BusStop>(
                        isExpanded: true,
                        value: _availableDropOffs.firstWhere(
                          (d) => d.id == tempDropOff.id,
                          orElse: () => _availableDropOffs.first,
                        ),
                        items: _availableDropOffs.map((stop) {
                          return DropdownMenuItem<BusStop>(
                            value: stop,
                            child: Text(
                              stop.name,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStop) {
                          if (newStop != null) {
                            setModalState(() {
                              tempDropOff = newStop;
                            });
                          }
                        },
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

                        // 1. Update state immediately
                        setState(() {
                          _currentPickup = tempPickup;
                          _currentDropOff = tempDropOff;
                          _buildStopsAndRoute();
                        });

                        // 2. Animate camera to fit new pickup & dropoff
                        _isProgrammaticCameraMove = true;
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(tempPickup.latitude, tempPickup.longitude),
                            14,
                          ),
                        );

                        // 3. Notify backend API
                        await _apiService.updateStops(
                          tripId: widget.tripId,
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

                        // 4. Refresh ETA
                        _refreshETA();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📍 Route updated: ${tempPickup.name} ➔ ${tempDropOff.name}'),
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
                        'Apply Changes to Map',
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
    _statusTicker?.cancel();
    _etaTicker?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Track School Bus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A)),
            ),
            Text(
              _tripDetails?.routeName ?? 'Morning Route • Bus #12',
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
              target: _initialPosition,
              zoom: 13.8,
            ),
            markers: _getAllMarkers(),
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onCameraMoveStarted: () {
              if (_isProgrammaticCameraMove) return;
              // Pause auto-following only if the user manually drags the map
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
              if (_latestLocation != null) {
                _recenterOnBus();
              }
            },
          ),

          // Top Floating Action Pill: Auto-Follow Indicator & Change Places Button
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Change Pickup/Drop-off button
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

                // Auto-follow indicator
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

          // Bottom Sheet with Real ETA, Driver, Vehicle & Places Info
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
                            const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF0D6B5D)),
                            const SizedBox(width: 5),
                            Text(
                              _latestEta != null
                                  ? 'Arriving in ${_latestEta!.etaMinutes} min • ${_latestEta!.distanceKm} km'
                                  : 'Calculating ETA...',
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

                    // Pickup and Drop-off summary strip
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
                              _currentPickup?.name ?? 'Pickup',
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
                              _currentDropOff?.name ?? 'School',
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

                    // Driver & Vehicle Details (Dynamic from Backend)
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
                                driver != null ? '${driver.name} (Driver)' : 'John Doe (Driver)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicle != null
                                    ? '${vehicle.plateNumber} • ${vehicle.model}'
                                    : 'WP NA-1234 • Ashok Leyland 32-Seater',
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
                            final phone = driver?.phone ?? '+94 77 123 4567';
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
