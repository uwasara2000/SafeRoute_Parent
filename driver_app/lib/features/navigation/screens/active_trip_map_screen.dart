import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../services/driver_location_service.dart';
import '../../incidents/screens/report_delay_screen.dart';

class ActiveTripMapScreen extends StatefulWidget {
  final String tripId;
  final String shift;
  final String driverName;

  const ActiveTripMapScreen({
    super.key,
    required this.tripId,
    required this.shift,
    required this.driverName,
  });

  @override
  State<ActiveTripMapScreen> createState() => _ActiveTripMapScreenState();
}

class _ActiveTripMapScreenState extends State<ActiveTripMapScreen> {
  final DriverLocationService _locationService = DriverLocationService();
  GoogleMapController? _mapController;

  bool _isBroadcasting = true;
  LatLng _currentPosition = const LatLng(6.8906, 79.8890); // Nawala Junction
  double _currentSpeedKmH = 32.0;
  int _currentStopIndex = 0;

  final List<Map<String, dynamic>> _stops = [
    {'name': 'Lake Road stop', 'lat': 6.8906, 'lng': 79.8890, 'students': 4},
    {'name': 'Temple Junction stop', 'lat': 6.8860, 'lng': 79.8885, 'students': 6},
    {'name': 'Nugegoda Junction stop', 'lat': 6.8745, 'lng': 79.8920, 'students': 3},
    {'name': 'Kirulapone stop', 'lat': 6.8722, 'lng': 79.8850, 'students': 4},
    {'name': 'Havelock Town stop', 'lat': 6.8770, 'lng': 79.8780, 'students': 3},
    {'name': 'Thimbirigasyaya stop', 'lat': 6.8850, 'lng': 79.8710, 'students': 4},
    {'name': 'Colombo Central College', 'lat': 6.9030, 'lng': 79.8615, 'students': 0},
  ];

  late final Set<Polyline> _polylines;
  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _initRouteData();
    _startLiveBroadcast();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  void _initRouteData() {
    final routePoints = DriverLocationService.route08Waypoints
        .map((wp) => LatLng(wp['lat']!, wp['lng']!))
        .toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route_08_path'),
        points: routePoints,
        color: const Color(0xFF0D6B5D),
        width: 5,
      ),
    };

    _updateMarkers();
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    // 1. Bus Marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('driver_bus'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(
          title: 'Fleet #NB-4821',
          snippet: 'School Bus • Live Broadcasting',
        ),
      ),
    );

    // 2. Stop Markers
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      final isNext = i == _currentStopIndex;
      newMarkers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop['lat'] as double, stop['lng'] as double),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isNext ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: stop['name'] as String,
            snippet: '${stop['students']} students',
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _startLiveBroadcast() {
    _locationService.startLocationBroadcast(
      tripId: widget.tripId,
      onLocationUpdated: (busLoc) {
        if (!mounted) return;
        setState(() {
          _currentPosition = LatLng(busLoc.latitude, busLoc.longitude);
          _currentSpeedKmH = ((busLoc.speedMps ?? 8.0) * 3.6).roundToDouble();
          _updateMarkers();
        });

        // Smooth camera follow
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      },
    );
  }

  void _toggleBroadcast() {
    if (_isBroadcasting) {
      _locationService.dispose();
      setState(() => _isBroadcasting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS broadcast paused.')),
      );
    } else {
      _startLiveBroadcast();
      setState(() => _isBroadcasting = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS broadcasting live to parent app.')),
      );
    }
  }

  void _advanceToNextStop() {
    if (_currentStopIndex < _stops.length - 1) {
      setState(() {
        _currentStopIndex++;
        _updateMarkers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arrived at ${_stops[_currentStopIndex]['name']}'),
          backgroundColor: AppColors.primaryTeal,
        ),
      );
    } else {
      _completeTrip();
    }
  }

  void _completeTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Trip?'),
        content: const Text(
          'All students have arrived at Royal College. Finish trip and close live GPS broadcast?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _locationService.stopLocationBroadcast(widget.tripId);
              if (mounted) {
                Navigator.pop(context, false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStop = _stops[_currentStopIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _isBroadcasting),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route 08 Navigation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${widget.shift} Shift • NB-4821',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBroadcasting ? Icons.wifi_tethering_rounded : Icons.portable_wifi_off_rounded,
              color: _isBroadcasting ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            onPressed: _toggleBroadcast,
            tooltip: _isBroadcasting ? 'Broadcasting live' : 'Broadcast paused',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
            onMapCreated: (ctrl) => _mapController = ctrl,
            polylines: _polylines,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // 2. Broadcast Status Floating Bar
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isBroadcasting ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isBroadcasting
                          ? 'BROADCASTING LIVE • PARENTS CAN SEE VEHICLE'
                          : 'BROADCAST PAUSED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isBroadcasting ? const Color(0xFF0D6B5D) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_currentSpeedKmH.toInt()} km/h',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Navigation & Control Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next Stop Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT TARGET STOP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: Color(0xFF0D6B5D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentStop['name'] as String,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3EBE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_currentStopIndex + 1} of ${_stops.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Delay Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportDelayScreen(
                                tripId: 'route_08',
                                routeName: 'Route 08',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: const Text('Delay'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFFDE68A)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Next Stop Reached / Complete Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _advanceToNextStop,
                          icon: Icon(
                            _currentStopIndex < _stops.length - 1
                                ? Icons.check_circle_outline_rounded
                                : Icons.flag_rounded,
                            size: 20,
                          ),
                          label: Text(
                            _currentStopIndex < _stops.length - 1
                                ? 'Arrived at Stop'
                                : 'Complete Trip',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
