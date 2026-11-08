import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/student_roster_item.dart';
import '../services/roster_service.dart';

class StudentRosterScreen extends StatefulWidget {
  final String tripId;

  const StudentRosterScreen({
    super.key,
    this.tripId = 'route_08',
  });

  @override
  State<StudentRosterScreen> createState() => _StudentRosterScreenState();
}

class _StudentRosterScreenState extends State<StudentRosterScreen> {
  final RosterService _rosterService = RosterService();
  List<StudentRosterItem> _roster = [];
  bool _isLoading = true;
  String _activeFilter = 'All'; // All, Waiting, Boarded, Absent

  @override
  void initState() {
    super.initState();
    _loadRoster();
  }

  Future<void> _loadRoster() async {
    final initial = _rosterService.getInitialRoster();
    final synced = await _rosterService.syncAbsences(initial);
    if (!mounted) return;
    setState(() {
      _roster = synced;
      _isLoading = false;
    });
  }

  int get _boardedCount =>
      _roster.where((s) => s.status == 'boarded' || s.status == 'dropped_off').length;

  List<StudentRosterItem> get _filteredRoster {
    if (_activeFilter == 'All') return _roster;
    if (_activeFilter == 'Boarded') {
      return _roster.where((s) => s.status == 'boarded' || s.status == 'dropped_off').toList();
    }
    if (_activeFilter == 'Waiting') {
      return _roster.where((s) => s.status == 'waiting').toList();
    }
    if (_activeFilter == 'Absent') {
      return _roster.where((s) => s.status == 'absent').toList();
    }
    return _roster;
  }

  void _updateStatus(StudentRosterItem student, String newStatus) async {
    setState(() {
      student.status = newStatus;
    });
    await _rosterService.updateStudentStatus(
      tripId: widget.tripId,
      student: student,
      newStatus: newStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _boardedCount),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Roster',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$_boardedCount of ${_roster.length} Boarded • Route 08',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadRoster();
            },
            tooltip: 'Sync Absences',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            )
          : Column(
              children: [
                // Filter Tabs
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _buildFilterChip('All', _roster.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Waiting', _roster.where((s) => s.status == 'waiting').length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Boarded', _boardedCount),
                      const SizedBox(width: 8),
                      _buildFilterChip('Absent', _roster.where((s) => s.status == 'absent').length),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: _filteredRoster.isEmpty
                      ? Center(
                          child: Text(
                            'No students in $_activeFilter list.',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRoster.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = _filteredRoster[index];
                            return _buildStudentCard(student);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentRosterItem student) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    if (student.status == 'boarded') {
      statusBg = const Color(0xFFD1FAE5);
      statusText = const Color(0xFF065F46);
      statusLabel = 'ON BOARD';
    } else if (student.status == 'dropped_off') {
      statusBg = const Color(0xFFE0E7FF);
      statusText = const Color(0xFF3730A3);
      statusLabel = 'DROPPED OFF';
    } else if (student.status == 'absent') {
      statusBg = const Color(0xFFFEE2E2);
      statusText = const Color(0xFF991B1B);
      statusLabel = student.absenceReported ? 'ABSENT (Reported)' : 'ABSENT';
    } else {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFF92400E);
      statusLabel = 'WAITING';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.grade} • Stop: ${student.stopName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),

          // Absence notice if reported by parent
          if (student.absenceReported && student.absenceReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFEA580C)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Parent Note: ${student.absenceReason}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9A3412)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parent: ${student.parentName}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  // Waiting button
                  if (student.status != 'waiting')
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, size: 20, color: Color(0xFF94A3B8)),
                      tooltip: 'Reset to Waiting',
                      onPressed: () => _updateStatus(student, 'waiting'),
                    ),

                  // Absent button
                  if (student.status != 'absent')
                    TextButton(
                      onPressed: () => _updateStatus(student, 'absent'),
                      child: const Text('Absent', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                    ),

                  // Boarded button
                  ElevatedButton(
                    onPressed: () {
                      if (student.status == 'boarded') {
                        _updateStatus(student, 'dropped_off');
                      } else {
                        _updateStatus(student, 'boarded');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: student.status == 'boarded'
                          ? const Color(0xFF3B82F6)
                          : AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      student.status == 'boarded' ? 'Drop Off' : 'Board',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
