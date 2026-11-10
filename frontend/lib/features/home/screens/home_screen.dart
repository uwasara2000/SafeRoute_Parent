import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../children/models/child_model.dart';
import '../../children/screens/my_children_screen.dart';
import '../../children/services/children_service.dart';
import '../../tracking/screens/live_tracking_screen.dart';
import '../../history/screens/journey_history_screen.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Screen: Parent Home Screen matching the design screenshot
class HomeScreen extends StatefulWidget {
  final String? parentName;

  const HomeScreen({super.key, this.parentName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChildrenService _childrenService = ChildrenService();
  final PageController _cardsPageController = PageController();
  late Stream<List<ChildModel>> _childrenStream;

  int _selectedNavIndex = 0;
  int _activeCardIndex = 0;
  String _displayName = 'Parent';
  String _initials = 'P';

  // Selected child for viewing on the dashboard
  ChildModel? _selectedChild;
  List<ChildModel> _allChildren = [];

  @override
  void initState() {
    super.initState();
    _childrenStream = _childrenService.getChildrenStream();
    _loadParentProfile();
  }

  @override
  void dispose() {
    _cardsPageController.dispose();
    super.dispose();
  }

  void _loadParentProfile() {
    if (widget.parentName != null && widget.parentName!.trim().isNotEmpty) {
      _setDisplayName(widget.parentName!.trim());
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (currentUser.displayName != null &&
          currentUser.displayName!.trim().isNotEmpty) {
        _setDisplayName(currentUser.displayName!.trim());
      }

      // Fetch from Firestore users/{uid}
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .then((doc) {
            if (doc.exists && mounted) {
              final data = doc.data();
              final fullName = data?['fullName'] as String?;
              if (fullName != null && fullName.trim().isNotEmpty) {
                _setDisplayName(fullName.trim());
              }
            }
          })
          .catchError((Object error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to load your profile details.'),
              ),
            );
          });
    }
  }

  void _setDisplayName(String name) {
    setState(() {
      final parts = name.split(' ');
      _displayName = parts.first; // e.g. "Nadeesha" or "Rashmi"
      if (parts.length >= 2) {
        _initials = '${parts.first[0]}${parts[1][0]}'.toUpperCase();
      } else if (name.length >= 2) {
        _initials = name.substring(0, 2).toUpperCase();
      } else {
        _initials = name.toUpperCase();
      }
    });
  }

  void _navigateToMyChildren() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyChildrenScreen(
          initialChildren: _allChildren,
          onSelectChild: (child) {
            final targetIndex = _allChildren.indexWhere(
              (c) => c.id == child.id,
            );
            if (targetIndex != -1 && _cardsPageController.hasClients) {
              _cardsPageController.animateToPage(
                targetIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            setState(() {
              _selectedChild = child;
              if (targetIndex != -1) _activeCardIndex = targetIndex;
            });
          },
        ),
      ),
    );
  }

  void _retryChildrenLoad() {
    setState(() {
      _childrenStream = _childrenService.getChildrenStream();
    });
  }

  void _navigateToTab(int index) {
    setState(() => _selectedNavIndex = index);
    if (index == 0) return;

    final selectedChild =
        _selectedChild ??
        (_allChildren.isNotEmpty
            ? _allChildren[_activeCardIndex
                  .clamp(0, _allChildren.length - 1)
                  .toInt()]
            : null);
    final Widget destination = switch (index) {
      1 => LiveTrackingScreen(initialChild: selectedChild),
      2 => JourneyHistoryScreen(initialChild: selectedChild?.name),
      3 => AlertsScreen(initialChild: selectedChild),
      4 => const ProfileScreen(),
      _ => const HomeScreen(),
    };

    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => destination))
        .whenComplete(() {
          if (mounted) setState(() => _selectedNavIndex = 0);
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChildModel>>(
      stream: _childrenStream,
      initialData: const [],
      builder: (context, snapshot) {
        _allChildren = snapshot.data ?? [];

        // Determine current child based on active swipe index or selected child
        ChildModel? currentChild;
        if (_allChildren.isNotEmpty) {
          if (_activeCardIndex >= 0 && _activeCardIndex < _allChildren.length) {
            currentChild = _allChildren[_activeCardIndex];
          } else {
            currentChild = _allChildren.first;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7FAF9),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          title: const Text(
                            'Unable to load your linked children.',
                            style: TextStyle(color: AppColors.error),
                          ),
                          trailing: TextButton(
                            onPressed: _retryChildrenLoad,
                            child: const Text('Retry'),
                          ),
                        ),
                      ),
                    ),
                  // 1. Header (Greeting + User Avatar)
                  _buildHeader(),
                  const SizedBox(height: 18),

                  // 2. Child Selector Pill / Card (Tapping arrow opens My Children list)
                  _buildChildSelectorCard(currentChild),
                  const SizedBox(height: 18),

                  // 3. Horizontal Swiping Green Live Trip Cards (1 card per child)
                  _buildHorizontalLiveTripCards(),
                  const SizedBox(height: 24),

                  // 4. Quick Actions Section
                  _buildQuickActions(currentChild),
                  const SizedBox(height: 24),

                  // 5. Upcoming Journey Section
                  _buildUpcomingJourney(currentChild),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  /// 1. Top Header with "Good morning", parent name and circular initials badge
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2E28),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFD3EBE5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D6B5D),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Child dropdown/selector card (Reflects current active swiped child)
  Widget _buildChildSelectorCard(ChildModel? child) {
    return InkWell(
      onTap: _navigateToMyChildren,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD3EBE5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                child?.initials ?? '?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D6B5D),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child?.name ?? 'No Child Selected',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    child != null
                        ? '${child.school} · ${child.grade}'
                        : 'Tap to view or link children',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF9CA3AF),
                size: 26,
              ),
              onPressed: _navigateToMyChildren,
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Horizontal Swiping Container for Live Trip Cards
  /// Displays 1 card if 1 child, 2 cards horizontally if 2 children, etc.
  Widget _buildHorizontalLiveTripCards() {
    if (_allChildren.isEmpty) {
      // Empty state for brand-new users before linking
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0D6B5D),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Active Journey',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Link your child in the "My Children" section to start tracking their school bus route.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToMyChildren,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D6B5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Open My Children'),
            ),
          ],
        ),
      );
    }

    // If 1 child only: display normal single card
    if (_allChildren.length == 1) {
      return _buildSingleLiveTripCard(_allChildren.first);
    }

    // If 2 or more children: display swipeable horizontal PageView with page indicator dots
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _cardsPageController,
            itemCount: _allChildren.length,
            onPageChanged: (index) {
              setState(() {
                _activeCardIndex = index;
                _selectedChild = _allChildren[index];
                _selectedChild = _allChildren[index];
              });
            },
            itemBuilder: (context, index) {
              final child = _allChildren[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildSingleLiveTripCard(child),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator showing which child card is currently active
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_allChildren.length, (index) {
            final isActive = _activeCardIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0D6B5D)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Single Dark Teal Live Trip Status Card (Exact design matching your uploaded image)
  Widget _buildSingleLiveTripCard(ChildModel child) {
    final firstName = child.name.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6B5D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B5D).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with "ON BOARD" tag and ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      child.status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                child.eta,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Status Title
          Text(
            '$firstName is on the way to school',
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),

          // Location & time indicator
          Row(
            children: [
              Icon(
                Icons.map_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  child.lastKnownLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bus Number & Route
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_bus_rounded,
                    size: 17,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    child.vehicleNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                child.route,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // "View Live Map" Button (Opens live map/roadmap for this child)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LiveTrackingScreen(initialChild: child),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D6B5D),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View Live Map',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D6B5D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Quick Actions grid
  Widget _buildQuickActions(ChildModel? child) {
    final name = child != null ? child.name.split(' ').first : 'child';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionItem(
              icon: Icons.map_outlined,
              label: 'Track bus',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LiveTrackingScreen(initialChild: child),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildActionItem(
              icon: Icons.person_outline,
              label: 'Report\nabsence',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report absence form for $name...')),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildActionItem(
              icon: Icons.access_time_rounded,
              label: 'Journey\nhistory',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JourneyHistoryScreen(initialChild: name),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildActionItem(
              icon: Icons.phone_outlined,
              label: 'Contact\noperator',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Calling transport operator for $name...'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 94,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF0D6B5D)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Upcoming Journey Card with visual timeline
  Widget _buildUpcomingJourney(ChildModel? child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Upcoming journey',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pickup Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child?.pickupTime ?? '7:15 AM',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child?.pickupLocation ?? 'Pickup stop',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),

              // Visual Timeline Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0D6B5D),
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 26,
                        color: const Color(0xFFD1D5DB),
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0D6B5D),
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Arrival Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Arrival',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child?.dropOffTime ?? '7:55 AM',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child?.school ?? 'School gate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom Navigation Bar (Home, Track, History, Alerts, Profile)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F2F4), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Track',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.access_time_rounded,
                activeIcon: Icons.access_time_filled_rounded,
                label: 'History',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: 'Alerts',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedNavIndex == index;
    return InkWell(
      onTap: () {
        _navigateToTab(index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFD3EBE5).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF0D6B5D)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0D6B5D)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
