import 'package:flutter/material.dart';
import '../../home/screens/driver_dashboard_screen.dart';
import '../../navigation/screens/driver_trips_screen.dart';
import '../../roster/screens/driver_students_screen.dart';
import '../../profile/screens/driver_profile_screen.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    this.isUnread = true,
  });
}

class DriverNotificationsScreen extends StatefulWidget {
  final String driverName;

  const DriverNotificationsScreen({
    super.key,
    this.driverName = 'Dilan',
  });

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  final int _currentNavIndex = 3;
  String _activeFilter = 'All'; // 'All' or 'Unread'

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      title: 'Safety checklist required',
      description: 'Complete all checks before the 7:10 AM departure.',
      time: '2 min ago',
      icon: Icons.warning_amber_rounded,
      isUnread: true,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Absence reported',
      description: 'Amaya Fernando will be absent for the morning journey.',
      time: '18 min ago',
      icon: Icons.people_outline_rounded,
      isUnread: true,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Route update approved',
      description: 'Temple Junction arrival updated to 7:36 AM.',
      time: 'Yesterday',
      icon: Icons.alt_route_rounded,
      isUnread: true,
    ),
    NotificationItem(
      id: 'n4',
      title: 'Vehicle assignment confirmed',
      description: 'You are assigned to NB-4578 for Monday.',
      time: 'Yesterday',
      icon: Icons.directions_bus_outlined,
      isUnread: false,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  List<NotificationItem> get _filteredNotifications {
    if (_activeFilter == 'Unread') {
      return _notifications.where((n) => n.isUnread).toList();
    }
    return _notifications;
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

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

                    // Top Header (UPDATES / Notifications + Mark all read)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPDATES',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.9,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _markAllRead,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              'Mark all read',
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
                    const SizedBox(height: 20),

                    // Filter Pills (All / Unread 3)
                    Row(
                      children: [
                        _buildFilterPill(
                          title: 'All',
                          isSelected: _activeFilter == 'All',
                          onTap: () => setState(() => _activeFilter = 'All'),
                        ),
                        const SizedBox(width: 8),
                        _buildUnreadPill(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Notifications List Card
                    Container(
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredNotifications.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF1F5F9),
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredNotifications[index];
                          return _buildNotificationTile(item);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
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

  Widget _buildFilterPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildUnreadPill() {
    final isSelected = _activeFilter == 'Unread';
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = 'Unread'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unread',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return InkWell(
      onTap: () {
        setState(() {
          item.isUnread = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Squircle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // Unread Blue Dot Indicator
            if (item.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                width: 7.5,
                height: 7.5,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverTripsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverStudentsScreen(driverName: widget.driverName),
            ),
          );
        } else if (index == 3) {
          // Already on Alerts
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

