class StudentRosterItem {
  final String id;
  final String name;
  final String grade;
  final String stopName;
  final String parentName;
  final String parentContact;
  String status; // 'waiting', 'boarded', 'dropped_off', 'absent'
  final bool absenceReported;
  final String? absenceReason;

  StudentRosterItem({
    required this.id,
    required this.name,
    required this.grade,
    required this.stopName,
    required this.parentName,
    required this.parentContact,
    this.status = 'waiting',
    this.absenceReported = false,
    this.absenceReason,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'grade': grade,
    'stopName': stopName,
    'parentName': parentName,
    'parentContact': parentContact,
    'status': status,
    'absenceReported': absenceReported,
    'absenceReason': absenceReason,
  };

  factory StudentRosterItem.fromMap(Map<String, dynamic> map) => StudentRosterItem(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    grade: map['grade'] ?? '',
    stopName: map['stopName'] ?? '',
    parentName: map['parentName'] ?? '',
    parentContact: map['parentContact'] ?? '',
    status: map['status'] ?? 'waiting',
    absenceReported: map['absenceReported'] ?? false,
    absenceReason: map['absenceReason'],
  );
}

