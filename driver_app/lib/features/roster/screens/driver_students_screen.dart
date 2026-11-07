import 'package:flutter/material.dart';
import '../../home/screens/driver_dashboard_screen.dart';
import '../../navigation/screens/driver_trips_screen.dart';
import '../../incidents/screens/driver_notifications_screen.dart';
import '../../profile/screens/driver_profile_screen.dart';

class DriverStudentItem {
  final String id;
  final String name;
  final String initials;
  final String grade;
  final String stopName;
  final Color avatarBg;
  final Color avatarText;
  String status; // 'BOARDED', 'EXPECTED', 'ABSENT'

  DriverStudentItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.grade,
    required this.stopName,
    required this.avatarBg,
    required this.avatarText,
    required this.status,
  });
}

class DriverStudentsScreen extends StatefulWidget {
  final String driverName;

  const DriverStudentsScreen({
    super.key,
    this.driverName = 'Dilan',
  });

  @override
  State<DriverStudentsScreen> createState() => _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends State<DriverStudentsScreen> {
  final int _currentNavIndex = 2;
  String _activeFilter = 'All'; // All, Expected, Boarded, Absent
  final TextEditingController _searchController = TextEditingController();

  final List<DriverStudentItem> _students = [
    DriverStudentItem(
      id: 's1',
      name: 'Maya Perera',
      initials: 'MP',
      grade: 'Grade 4A',
      stopName: 'Lake Road',
      avatarBg: const Color(0xFFFFEDD5),
      avatarText: const Color(0xFFC2410C),
      status: 'BOARDED',
    ),
    DriverStudentItem(
      id: 's2',
      name: 'Nimal Silva',
      initials: 'NS',
      grade: 'Grade 5B',
      stopName: 'Temple Junction',
      avatarBg: const Color(0xFFDBEAFE),
      avatarText: const Color(0xFF1D4ED8),
      status: 'EXPECTED',
    ),
    DriverStudentItem(
      id: 's3',
      name: 'Amaya Fernando',
      initials: 'AF',
      grade: 'Grade 3A',
      stopName: 'Park Avenue',
      avatarBg: const Color(0xFFF3E8FF),
      avatarText: const Color(0xFF7E22CE),
      status: 'ABSENT',
    ),
    DriverStudentItem(
      id: 's4',
      name: 'Kavin Raj',
      initials: 'KR',
      grade: 'Grade 6C',
      stopName: 'Lake Road',
      avatarBg: const Color(0xFFD1FAE5),
      avatarText: const Color(0xFF0D9488),
      status: 'EXPECTED',
    ),
    DriverStudentItem(
      id: 's5',
      name: 'Tharindu Jayasuriya',
      initials: 'TJ',
      grade: 'Grade 7A',
      stopName: 'Kirulapone',
      avatarBg: const Color(0xFFFEF3C7),
      avatarText: const Color(0xFFB45309),
      status: 'BOARDED',
    ),
    DriverStudentItem(
      id: 's6',
      name: 'Senuri Perera',
      initials: 'SP',
      grade: 'Grade 4D',
      stopName: 'Nugegoda',
      avatarBg: const Color(0xFFE0E7FF),
      avatarText: const Color(0xFF4338CA),
      status: 'BOARDED',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _expectedCount => 24;
  int get _boardedCount =>
      18 + _students.where((s) => s.status == 'BOARDED').length - 3;
  int get _absentCount => 2;

  List<DriverStudentItem> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    return _students.where((student) {
      final matchesQuery = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.stopName.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_activeFilter == 'All') return true;
      if (_activeFilter == 'Expected') return student.status == 'EXPECTED';
      if (_activeFilter == 'Boarded') return student.status == 'BOARDED';
      if (_activeFilter == 'Absent') return student.status == 'ABSENT';
      return true;
    }).toList();
  }

  void _boardStudent(DriverStudentItem student) {
    setState(() {
      student.status = 'BOARDED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.name} marked as Boarded.'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _openScanModal() {
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 38,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Student NFC / QR Check-in',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hold student ID badge against phone or scan barcode to automatically record boarding.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final unboarded = _students.firstWhere(
                    (s) => s.status == 'EXPECTED',
                    orElse: () => _students.first,
                  );
                  _boardStudent(unboarded);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simulate Scan & Board', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReconciliationModal() {
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
                    color: const Color(0xFF0F223D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End-of-Trip Reconciliation',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Bus Interior Child Safety Check',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Text(
                'By confirming, driver and attendant certify that the entire bus aisle, seats, and rear floor have been physically inspected and all 24 students have safely exited.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF1E3A8A), height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reconciliation confirmed. Trip safely finalized!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F223D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm Bus Clear & Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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

                    // Top Header (MORNING ROUTE / Students + Scan Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MORNING ROUTE',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.9,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Students',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),

                        // Scan Pill Button
                        InkWell(
                          onTap: _openScanModal,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 19,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Scan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Summary Stats Hero Card (Dark Navy)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F223D),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F223D).withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildSummaryStat(number: '$_expectedCount', label: 'Expected'),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _buildSummaryStat(number: '$_boardedCount', label: 'Boarded'),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _buildSummaryStat(number: '$_absentCount', label: 'Absent'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          hintText: 'Search student name',
                          hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                          prefixIcon: Icon(
                            Icons.people_outline_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter Chips (All, Expected, Boarded, Absent)
                    Row(
                      children: [
                        _buildFilterPill('All'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Expected'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Boarded'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Absent'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Student List Cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredStudents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return _buildStudentCard(student);
                      },
                    ),
                    const SizedBox(height: 18),

                    // End-of-Trip Reconciliation Card
                    InkWell(
                      onTap: _openReconciliationModal,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F223D),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F223D).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End-of-trip reconciliation',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Required before completing trip',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
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

  Widget _buildSummaryStat({required String number, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F223D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(DriverStudentItem student) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initials Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: student.avatarBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: student.avatarText,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.grade} • ${student.stopName}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Status & Board Button
          _buildStudentStatusTrailing(student),
        ],
      ),
    );
  }

  Widget _buildStudentStatusTrailing(DriverStudentItem student) {
    if (student.status == 'BOARDED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'BOARDED',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF15803D),
          ),
        ),
      );
    } else if (student.status == 'ABSENT') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'ABSENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF64748B),
          ),
        ),
      );
    } else {
      // EXPECTED status + Board button
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'EXPECTED',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () => _boardStudent(student),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Board',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
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
          // Already on Students
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

