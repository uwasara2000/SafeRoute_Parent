import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_location.dart';
import '../services/bus_tracking_service.dart';

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

  GoogleMapController? _mapController;
  StreamSubscription<BusLocation?>? _locationSubscription;
  StreamSubscription<bool>? _tripStatusSubscription;

  BusLocation? _latestLocation;
  bool _isTripActive = true;
  Marker? _busMarker;
  Timer? _statusTicker;

  // Default fallback camera (Colombo, Sri Lanka demo position)
  static const LatLng _initialPosition = LatLng(6.9271, 79.8612);

  @override
  void initState() {
    super.initState();
    _subscribeToTrip();

    // Re-render every 5 seconds to update "Updated X seconds ago" label
    _statusTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'School Bus',
          snippet: 'Live Tracked',
        ),
      );
    });

    // Smoothly animate camera to new bus coordinates
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(busLatLng),
    );
  }

  void _recenterOnBus() {
    if (_latestLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_latestLocation!.latitude, _latestLocation!.longitude),
          16.0,
        ),
      );
    }
  }

  String _getTimeAgoString() {
    if (_latestLocation == null) return 'Waiting for signal...';
    final difference = DateTime.now().difference(_latestLocation!.updatedAt);
    if (difference.inSeconds < 15) {
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
    if (diff.inSeconds <= 20) return Colors.green;
    if (diff.inMinutes <= 2) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _tripStatusSubscription?.cancel();
    _statusTicker?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track School Bus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Morning Route • Bus #12',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Chip(
              avatar: CircleAvatar(
                radius: 4,
                backgroundColor: _getStatusColor(),
              ),
              label: Text(
                _isTripActive ? _getTimeAgoString() : 'Trip Ended',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14.5,
            ),
            markers: _busMarker != null ? {_busMarker!} : {},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_latestLocation != null) {
                _recenterOnBus();
              }
            },
          ),

          // Map Control Buttons (Recenter, Zoom)
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: Colors.white,
                  onPressed: _recenterOnBus,
                  child: const Icon(Icons.my_location, color: Colors.blueAccent),
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

          // Bottom Sheet with Journey & Driver details
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ON BOARD',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Text(
                          'Estimated Arrival ~ 14 min',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Driver & Vehicle row
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.directions_bus, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe (Driver)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Vehicle: WP NA-1234 • Ashok Leyland',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling Driver...')),
                            );
                          },
                        ),
                      ],
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

