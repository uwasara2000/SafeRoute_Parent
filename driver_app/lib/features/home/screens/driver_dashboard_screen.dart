import 'package:flutter/material.dart';
import '../../navigation/screens/active_trip_map_screen.dart';
import '../../navigation/screens/trip_details_screen.dart';
import '../../navigation/screens/driver_trips_screen.dart';
import '../../navigation/screens/route_stops_screen.dart';
import '../../roster/screens/driver_students_screen.dart';
import '../../incidents/screens/report_delay_screen.dart';
import '../../incidents/screens/emergency_alert_screen.dart';
import '../../incidents/screens/driver_notifications_screen.dart';
import '../../profile/screens/driver_profile_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  final String driverName;

  const DriverDashboardScreen({
    super.key,
    this.driverName = 'Dilan',
  });

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  int _currentNavIndex = 0;

  // Staggered Slide & Fade Animations
  late final Animation<Offset> _statusSlide;
  late final Animation<double> _statusFade;

  late final Animation<Offset> _vehicleSlide;
  late final Animation<double> _vehicleFade;

  late final Animation<Offset> _actionsSlide;
  late final Animation<double> _actionsFade;

  late final Animation<Offset> _stopsSlide;
  late final Animation<double> _stopsFade;

  late final Animation<Offset> _safetySlide;
  late final Animation<double> _safetyFade;

  @override
  void initState() {
    super.initState();

    // 1. Glowing Pulse Animation for Live Status
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.9, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.65, end: 0.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Entrance Choreography
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _statusSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
      ),
    );
    _statusFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _vehicleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _vehicleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.50, curve: Curves.easeOut),
      ),
    );

    _actionsSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _actionsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
      ),
    );

    _stopsSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _stopsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    _safetySlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _safetyFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.70, 0.95, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _showGpsStatusDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS Telematics Status',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Real-time vehicle position stream',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGpsRow('GPS Hardware Fix', 'Active • 14 Satellites Locked', const Color(0xFF10B981)),
            _buildGpsRow('Broadcast Latency', '42 ms (Direct RTDB sync)', const Color(0xFF10B981)),
            _buildGpsRow('Positional Accuracy', '± 3.8 meters (High Precision)', const Color(0xFF10B981)),
            _buildGpsRow('Live Stream Channel', 'liveTrips/route_07/location', const Color(0xFF2563EB)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Close Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsRow(String label, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Row(
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLiveMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveTripMapScreen(
          tripId: 'route_07',
          shift: 'Morning',
          driverName: widget.driverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Deep Navy Header
                _buildNavyHeader(),

                // 2. Overlapping Ready to Start Status Card
                SlideTransition(
                  position: _statusSlide,
                  child: FadeTransition(
                    opacity: _statusFade,
                    child: Transform.translate(
                      offset: const Offset(0, -26),
                      child: _buildReadyToStartCard(),
                    ),
                  ),
                ),

                // 3. Assigned Vehicle & Today's Route Card
                SlideTransition(
                  position: _vehicleSlide,
                  child: FadeTransition(
                    opacity: _vehicleFade,
                    child: Transform.translate(
                      offset: const Offset(0, -14),
                      child: _buildAssignedVehicleAndRouteCard(),
                    ),
                  ),
                ),

                // 4. Quick Actions (2x2 Grid)
                SlideTransition(
                  position: _actionsSlide,
                  child: FadeTransition(
                    opacity: _actionsFade,
                    child: _buildQuickActionsSection(),
                  ),
                ),

                // 5. Next Stops
                SlideTransition(
                  position: _stopsSlide,
                  child: FadeTransition(
                    opacity: _stopsFade,
                    child: _buildNextStopsSection(),
                  ),
                ),

                // 6. Safety First Notice
                SlideTransition(
                  position: _safetySlide,
                  child: FadeTransition(
                    opacity: _safetyFade,
                    child: _buildSafetyBanner(),
                  ),
                ),

                const SizedBox(height: 90), // Spacing for bottom navigation bar
              ],
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Navy Header
  // ---------------------------------------------------------------------------
  Widget _buildNavyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 52, bottom: 48),
      decoration: const BoxDecoration(
        color: Color(0xFF0C1E38),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MONDAY, 24 JUNE',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                  color: Color(0xFF8FA0B8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Good morning, ${widget.driverName}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Driver • SafeRoute Transport',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8FA0B8),
                ),
              ),
            ],
          ),

          // Profile Avatar with Online Indicator
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DriverProfileScreen(driverName: widget.driverName),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'DP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0C1E38), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Status Card ("Ready to start")
  // ---------------------------------------------------------------------------
  Widget _buildReadyToStartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Amber Glowing Indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 22 * _pulseScale.value,
                    height: 22 * _pulseScale.value,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: _pulseOpacity.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 14),

          // Status Information
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to start',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Morning route • 7:10 AM',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // ON TIME Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ON TIME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Assigned Vehicle & Today's Route Combined Card
  // ---------------------------------------------------------------------------
  Widget _buildAssignedVehicleAndRouteCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Part 1: Assigned Vehicle
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripDetailsScreen(
                    tripId: 'route_07',
                    routeName: 'Route 07 • Lake Road',
                    vehicleNumber: 'NB-4578',
                    driverName: widget.driverName,
                  ),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.directions_bus_outlined,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNED VEHICLE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'NB-4578',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Ashok Leyland • 32 seats',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),

          // Subtle Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Part 2: Today's Route
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Route details
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY\'S ROUTE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Route 07 • Lake Road',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Colombo Central College',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Counter Stats
                    Row(
                      children: [
                        _buildRouteStat(number: '24', label: 'students'),
                        const SizedBox(width: 18),
                        _buildRouteStat(number: '8', label: 'stops'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Scheduled Departure Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF2563EB),
                        size: 19,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Scheduled departure',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '7:10 AM',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStat({required String number, required String label}) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Quick Actions Section (2x2 Grid)
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick actions',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: _navigateToLiveMap,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'View trip',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Actions
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'View route',
                  icon: Icons.alt_route_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RouteStopsScreen(
                          driverName: widget.driverName,
                          routeName: 'Route 07 • Lake Road',
                          vehicleNumber: 'NB-4578',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  title: 'GPS status',
                  icon: Icons.gps_fixed_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  onTap: _showGpsStatusDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Report delay',
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReportDelayScreen(
                          tripId: 'route_07',
                          routeName: 'Route 07 • Lake Road',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  title: 'Emergency',
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFEF4444),
                  iconBg: const Color(0xFFFEF2F2),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmergencyAlertScreen(
                          tripId: 'route_07',
                          driverName: widget.driverName,
                          vehicleNumber: 'NB-4578',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return _PressableScaleCard(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Next Stops Section
  // ---------------------------------------------------------------------------
  Widget _buildNextStopsSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next stops',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DriverStudentsScreen(driverName: widget.driverName),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Next Stops Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stop 1 (Active Next Stop)
                _buildStopItem(
                  number: '1',
                  isNext: true,
                  name: 'Lake Road',
                  subtext: '4 students • Arriving 7:28 AM',
                  hasBadge: true,
                  onTap: _navigateToLiveMap,
                ),

                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                // Stop 2
                _buildStopItem(
                  number: '2',
                  isNext: false,
                  name: 'Temple Junction',
                  subtext: '6 students • 7:36 AM',
                  hasBadge: false,
                  onTap: _navigateToLiveMap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem({
    required String number,
    required bool isNext,
    required String name,
    required String subtext,
    required bool hasBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            // Stop Number Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isNext ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isNext ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Stop Name & Arrival info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Blue NEXT Badge
            if (hasBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Safety First Notice Banner
  // ---------------------------------------------------------------------------
  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFF2563EB),
            size: 24,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety first',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Only use the app when the vehicle is safely stopped.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(index: 0, label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
          _buildNavItem(index: 1, label: 'Trips', icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded),
          _buildNavItem(index: 2, label: 'Students', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
          _buildNavItem(index: 3, label: 'Alerts', icon: Icons.notifications_none_rounded, activeIcon: Icons.notifications_rounded),
          _buildNavItem(index: 4, label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverTripsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverStudentsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 3) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverNotificationsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 4) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverProfileScreen(driverName: widget.driverName),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper interactive widget for tactile card press animations
class _PressableScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScaleCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableScaleCard> createState() => _PressableScaleCardState();
}

class _PressableScaleCardState extends State<_PressableScaleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
