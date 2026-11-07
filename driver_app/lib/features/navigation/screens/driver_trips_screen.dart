import 'package:flutter/material.dart';
import 'trip_details_screen.dart';
import '../../home/screens/driver_dashboard_screen.dart';
import '../../roster/screens/driver_students_screen.dart';
import '../../incidents/screens/driver_notifications_screen.dart';
import '../../profile/screens/driver_profile_screen.dart';

class DriverTripsScreen extends StatefulWidget {
  final String driverName;

  const DriverTripsScreen({
    super.key,
    this.driverName = 'Dilan',
  });

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  int _selectedTab = 0; // 0: Today, 1: Upcoming, 2: History
  final int _currentNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Top Header (OPERATIONS / Trips + Bell Icon)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OPERATIONS',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.9,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Trips',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),

                        // Notification Bell Container
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All operations on schedule.')),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF0F172A),
                                  size: 22,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 11,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Segmented Control (Today, Upcoming, History)
                    Container(
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentItem(index: 0, title: 'Today'),
                          _buildSegmentItem(index: 1, title: 'Upcoming'),
                          _buildSegmentItem(index: 2, title: 'History'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Date & Trip Count Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTab == 0
                              ? 'Today, 24 June'
                              : _selectedTab == 1
                                  ? 'Upcoming Trips'
                                  : 'Completed History',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _selectedTab == 0 ? '2 trips' : '1 trip',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tab Content
                    if (_selectedTab == 0) ...[
                      // Trip Card 1 (Morning School Route - READY)
                      _buildTripCard(
                        statusBadge: 'READY',
                        statusColor: const Color(0xFF2563EB),
                        statusBg: const Color(0xFFEFF6FF),
                        tripCode: 'TRP-240624-01',
                        title: 'Morning School Route',
                        subtitle: 'Colombo Central College',
                        time: '7:10 AM',
                        vehicle: 'NB-4578',
                        studentsCount: '24',
                        hasTopAccent: true,
                        showActionButton: true,
                        onAction: () {
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
                      ),
                      const SizedBox(height: 16),

                      // Trip Card 2 (Afternoon Return Route - UPCOMING)
                      _buildTripCard(
                        statusBadge: 'UPCOMING',
                        statusColor: const Color(0xFF64748B),
                        statusBg: const Color(0xFFF1F5F9),
                        tripCode: 'TRP-240624-02',
                        title: 'Afternoon Return Route',
                        subtitle: 'Colombo Central College',
                        time: '1:45 PM',
                        vehicle: 'NB-4578',
                        studentsCount: '22',
                        hasTopAccent: false,
                        showActionButton: false,
                        onAction: null,
                      ),
                    ] else if (_selectedTab == 1) ...[
                      _buildTripCard(
                        statusBadge: 'UPCOMING',
                        statusColor: const Color(0xFF64748B),
                        statusBg: const Color(0xFFF1F5F9),
                        tripCode: 'TRP-250624-01',
                        title: 'Tomorrow Morning Service',
                        subtitle: 'Colombo Central College',
                        time: '7:10 AM',
                        vehicle: 'NB-4578',
                        studentsCount: '24',
                        hasTopAccent: false,
                        showActionButton: false,
                        onAction: null,
                      ),
                    ] else ...[
                      _buildTripCard(
                        statusBadge: 'COMPLETED',
                        statusColor: const Color(0xFF10B981),
                        statusBg: const Color(0xFFD1FAE5),
                        tripCode: 'TRP-230624-02',
                        title: 'Sunday Special Shuttle',
                        subtitle: 'Royal College Sports Complex',
                        time: '4:00 PM',
                        vehicle: 'NB-4578',
                        studentsCount: '18',
                        hasTopAccent: false,
                        showActionButton: false,
                        onAction: null,
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Persistent Bottom Navigation Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem({required int index, required String title}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required String statusBadge,
    required Color statusColor,
    required Color statusBg,
    required String tripCode,
    required String title,
    required String subtitle,
    required String time,
    required String vehicle,
    required String studentsCount,
    required bool hasTopAccent,
    required bool showActionButton,
    required VoidCallback? onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Top Accent Line (as in Image)
            if (hasTopAccent)
              Container(
                height: 3.5,
                width: double.infinity,
                color: const Color(0xFF2563EB),
              ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge & Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Text(
                        tripCode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Route Title & School
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  // Icons Metadata Row (Time, Vehicle, Students)
                  Row(
                    children: [
                      // Time
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Vehicle
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_outlined, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            vehicle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Students
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            studentsCount,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Button
                  if (showActionButton && onAction != null) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View trip details',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverDashboardScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 1) {
          // Already on Trips
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverStudentsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 3) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverNotificationsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 4) {
          Navigator.of(context).pushReplacement(
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

