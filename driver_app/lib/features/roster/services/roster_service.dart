import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_roster_item.dart';

class RosterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Default Roster for Route 08 (Nawala to Royal College)
  List<StudentRosterItem> getInitialRoster() {
    return [
      StudentRosterItem(
        id: 'std_01',
        name: 'Amaya Silva',
        grade: 'Grade 5-B',
        stopName: 'Nawala Road stop',
        parentName: 'Dinuka Silva',
        parentContact: '+94 77 123 4567',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_02',
        name: 'Dineth Silva',
        grade: 'Grade 2-A',
        stopName: 'Nawala Road stop',
        parentName: 'Dinuka Silva',
        parentContact: '+94 77 123 4567',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_03',
        name: 'Kavindu Perera',
        grade: 'Grade 6-C',
        stopName: 'Open University stop',
        parentName: 'Sunil Perera',
        parentContact: '+94 71 987 6543',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_04',
        name: 'Senuri Fernando',
        grade: 'Grade 4-D',
        stopName: 'Nugegoda Junction stop',
        parentName: 'Ayesha Fernando',
        parentContact: '+94 76 555 1212',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_05',
        name: 'Tharindu Jayasuriya',
        grade: 'Grade 7-A',
        stopName: 'Kirulapone stop',
        parentName: 'Rohan Jayasuriya',
        parentContact: '+94 72 345 6789',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_06',
        name: 'Minoli De Silva',
        grade: 'Grade 3-B',
        stopName: 'Havelock Town stop',
        parentName: 'Chamari De Silva',
        parentContact: '+94 70 888 9999',
        status: 'waiting',
      ),
      StudentRosterItem(
        id: 'std_07',
        name: 'Oshada Wickramasinghe',
        grade: 'Grade 8-B',
        stopName: 'Thimbirigasyaya stop',
        parentName: 'Priyantha Wickramasinghe',
        parentContact: '+94 77 444 3322',
        status: 'waiting',
      ),
    ];
  }

  /// Check absences reported by parents in Firestore
  Future<List<StudentRosterItem>> syncAbsences(List<StudentRosterItem> roster) async {
    try {
      final snapshot = await _firestore.collection('absences').get();
      final reportedNames = <String, String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final childName = data['childName'] as String?;
        final reason = data['reason'] as String? ?? 'Parent reported absence';
        if (childName != null && childName.trim().isNotEmpty) {
          reportedNames[childName.trim().toLowerCase()] = reason;
        }
      }

      return roster.map((student) {
        final key = student.name.trim().toLowerCase();
        if (reportedNames.containsKey(key)) {
          return StudentRosterItem(
            id: student.id,
            name: student.name,
            grade: student.grade,
            stopName: student.stopName,
            parentName: student.parentName,
            parentContact: student.parentContact,
            status: 'absent',
            absenceReported: true,
            absenceReason: reportedNames[key],
          );
        }
        return student;
      }).toList();
    } catch (_) {
      return roster;
    }
  }

  /// Record boarding / dropoff event in Firestore
  Future<void> updateStudentStatus({
    required String tripId,
    required StudentRosterItem student,
    required String newStatus,
  }) async {
    try {
      student.status = newStatus;
      await _firestore.collection('boardingEvents').add({
        'tripId': tripId,
        'studentId': student.id,
        'studentName': student.name,
        'stopName': student.stopName,
        'status': newStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

