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

  Marker? _busMarker;
  final Set<Marker> _stopMarkers = {};
  final Set<Polyline> _polylines = {};
  Timer? _statusTicker;
  Timer? _etaTicker;

  // Default initial camera position (Colombo area)
  static const LatLng _initialPosition = LatLng(6.9271, 79.8612);

  @override
  void initState() {
    super.initState();
    _loadTripDetailsAndStops();
    _subscribeToTrip();

    // Re-render every 4 seconds to update "Updated X seconds ago" freshness label
    _statusTicker = Timer.periodic(const Duration(seconds: 4), (_) {
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
        _buildStopsAndRoute(details);
      }
    });

    _refreshETA();
  }

  void _buildStopsAndRoute(TripDetails details) {
    _stopMarkers.clear();
    _polylines.clear();

    final List<LatLng> routePoints = [];

    for (int i = 0; i < details.stops.length; i++) {
      final stop = details.stops[i];
      final pos = LatLng(stop.latitude, stop.longitude);
      routePoints.add(pos);

      final isFirst = i == 0;
      final isLast = i == details.stops.length - 1;

      double hue;
      String snippet;
      if (isFirst) {
        hue = BitmapDescriptor.hueGreen;
        snippet = 'Child Pickup Stop';
      } else if (isLast) {
        hue = BitmapDescriptor.hueRed;
        snippet = 'Final Destination (School)';
      } else {
        hue = BitmapDescriptor.hueAzure;
        snippet = 'Stop #${stop.order}';
      }

      _stopMarkers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: snippet,
          ),
        ),
      );
    }

    // Connect stops with a smooth polyline
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

    // Smoothly pan camera to following bus coordinates
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(busLatLng),
    );
  }

  void _recenterOnBus() {
    if (_latestLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_latestLocation!.latitude, _latestLocation!.longitude),
          15.5,
        ),
      );
    } else if (_tripDetails != null && _tripDetails!.stops.isNotEmpty) {
      final firstStop = _tripDetails!.stops.first;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(firstStop.latitude, firstStop.longitude), 14),
      );
    }
  }

  String _getTimeAgoString() {
    if (_latestLocation == null) return 'Waiting for GPS signal...';
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
    if (diff.inSeconds <= 15) return const Color(0xFF22C55E); // Bright Green
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
            onMapCreated: (controller) {
              _mapController = controller;
              if (_latestLocation != null) {
                _recenterOnBus();
              }
            },
          ),

          // Map Control Buttons (Recenter, Zoom In/Out)
          Positioned(
            right: 16,
            bottom: 270,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: Colors.white,
                  onPressed: _recenterOnBus,
                  child: const Icon(Icons.my_location, color: Color(0xFF0D6B5D)),
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

          // Bottom Sheet with Real ETA, Driver & Vehicle Info
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
                                _isTripActive ? 'ON BOARD' : 'COMPLETED',
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

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),

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

                    const SizedBox(height: 14),

                    // Navigation to Journey History
                    SizedBox(
                      width: double.infinity,
                      height: 42,
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
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
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
