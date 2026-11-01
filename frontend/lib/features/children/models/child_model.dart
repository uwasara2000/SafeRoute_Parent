import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a Child associated with a parent
class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final String school;
  final String grade;
  final String route;
  final String vehicleNumber;
  final String status; // e.g. "ON BOARD", "AT SCHOOL", "HOME", etc.
  final String eta;
  final String lastKnownLocation;
  final String schoolInfo;
  final String pickupLocation;
  final String pickupTime;
  final String dropOffLocation;
  final String dropOffTime;
  final String transportOperator;
  final String authorizedGuardians;
  final String emergencyContact;
  final String initials;

  const ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.school,
    required this.grade,
    required this.route,
    required this.vehicleNumber,
    required this.status,
    this.eta = 'ETA 7:48 AM',
    this.lastKnownLocation = 'Near Horton Place · updated 2 min ago',
    required this.schoolInfo,
    required this.pickupLocation,
    this.pickupTime = '7:15 AM',
    required this.dropOffLocation,
    this.dropOffTime = '7:55 AM',
    required this.transportOperator,
    required this.authorizedGuardians,
    required this.emergencyContact,
    required this.initials,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChildModel(
      id: docId,
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      school: map['school'] ?? '',
      grade: map['grade'] ?? '',
      route: map['route'] ?? 'Route 08',
      vehicleNumber: map['vehicleNumber'] ?? 'NB-4821',
      status: map['status'] ?? 'ON BOARD',
      eta: map['eta'] ?? 'ETA 7:48 AM',
      lastKnownLocation: map['lastKnownLocation'] ?? 'Near Horton Place · updated 2 min ago',
      schoolInfo: map['schoolInfo'] ?? '${map['school'] ?? ''}, Colombo 07',
      pickupLocation: map['pickupLocation'] ?? 'Nawala Road stop',
      pickupTime: map['pickupTime'] ?? '7:15 AM',
      dropOffLocation: map['dropOffLocation'] ?? '${map['school'] ?? ''} main gate',
      dropOffTime: map['dropOffTime'] ?? '7:55 AM',
      transportOperator: map['transportOperator'] ?? 'City School Transport',
      authorizedGuardians: map['authorizedGuardians'] ?? 'Authorized Guardian',
      emergencyContact: map['emergencyContact'] ?? '+94 77 555 0199',
      initials: map['initials'] ?? _computeInitials(map['name'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'school': school,
      'grade': grade,
      'route': route,
      'vehicleNumber': vehicleNumber,
      'status': status,
      'eta': eta,
      'lastKnownLocation': lastKnownLocation,
      'schoolInfo': schoolInfo,
      'pickupLocation': pickupLocation,
      'pickupTime': pickupTime,
      'dropOffLocation': dropOffLocation,
      'dropOffTime': dropOffTime,
      'transportOperator': transportOperator,
      'authorizedGuardians': authorizedGuardians,
      'emergencyContact': emergencyContact,
      'initials': initials,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'AS';
  }

  /// Amaya Silva (Child 1 in Sri Lanka school flow)
  static ChildModel defaultAmaya(String parentId) {
    return ChildModel(
      id: 'child_amaya',
      parentId: parentId,
      name: 'Amaya Silva',
      school: 'Royal College',
      grade: 'Grade 6A',
      route: 'Route 08',
      vehicleNumber: 'NB-4821',
      status: 'ON BOARD',
      eta: 'ETA 7:48 AM',
      lastKnownLocation: 'Near Horton Place · updated 2 min ago',
      schoolInfo: 'Royal College, Colombo 07',
      pickupLocation: 'Nawala Road stop',
      pickupTime: '7:15 AM',
      dropOffLocation: 'Royal College main gate',
      dropOffTime: '7:55 AM',
      transportOperator: 'City School Transport',
      authorizedGuardians: 'Nadeesha Perera, Sunil Silva',
      emergencyContact: '+94 77 555 0199',
      initials: 'AS',
    );
  }

  /// Dineth Silva (Child 2 in a different Sri Lanka school e.g. Ananda College or Visakha)
  static ChildModel defaultSecondChild(String parentId) {
    return ChildModel(
      id: 'child_dineth',
      parentId: parentId,
      name: 'Dineth Silva',
      school: 'Ananda College',
      grade: 'Grade 4B',
      route: 'Route 14',
      vehicleNumber: 'WP-3156',
      status: 'ON BOARD',
      eta: 'ETA 7:50 AM',
      lastKnownLocation: 'Near Maradana Junction · updated 1 min ago',
      schoolInfo: 'Ananda College, Colombo 10',
      pickupLocation: 'Rajagiriya Junction stop',
      pickupTime: '7:10 AM',
      dropOffLocation: 'Ananda College primary gate',
      dropOffTime: '7:50 AM',
      transportOperator: 'Colombo Metro School Buses',
      authorizedGuardians: 'Nadeesha Perera, Sunil Silva',
      emergencyContact: '+94 77 555 0199',
      initials: 'DS',
    );
  }
}
