import 'package:flutter/material.dart';
import 'package:saferoute_parent/screens/alerts_screen.dart';
import 'package:saferoute_parent/screens/home_screen.dart';
import 'package:saferoute_parent/screens/journey_history_screen.dart';
import 'package:saferoute_parent/screens/profile_screen.dart';
import 'package:saferoute_parent/screens/track_screen.dart';
import 'package:saferoute_parent/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2; // Default selected tab: History (center)

  final List<Widget> _screens = const [
    HomeScreen(),
    TrackScreen(),
    JourneyHistoryScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  Widget _buildHistoryIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.history,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: _buildHistoryIcon(),
            activeIcon: _buildHistoryIcon(),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
