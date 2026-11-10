import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a Child associated with a parent
class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final String school;
  final String grade;
  final String route;
  final String? routeId;
  final String? tripId;
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
    this.routeId,
    this.tripId,
    required this.vehicleNumber,
    required this.status,
    this.eta = '',
    this.lastKnownLocation = 'No trip updates yet',
    required this.schoolInfo,
    required this.pickupLocation,
    this.pickupTime = '',
    required this.dropOffLocation,
    this.dropOffTime = '',
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
      route: map['route'] ?? '',
      routeId: map['routeId']?.toString(),
      tripId: map['tripId']?.toString(),
      vehicleNumber: map['vehicleNumber'] ?? '',
      status: map['status'] ?? 'Not yet linked',
      eta: map['eta'] ?? '',
      lastKnownLocation: map['lastKnownLocation'] ?? 'No trip updates yet',
      schoolInfo: map['schoolInfo'] ?? map['school'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      pickupTime: map['pickupTime'] ?? '',
      dropOffLocation: map['dropOffLocation'] ?? '',
      dropOffTime: map['dropOffTime'] ?? '',
      transportOperator: map['transportOperator'] ?? '',
      authorizedGuardians: map['authorizedGuardians'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      initials: map['initials'] ?? _computeInitials(map['name'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'school': school,
      'grade': grade,
      if (route.trim().isNotEmpty) 'route': route.trim(),
      if (routeId?.trim().isNotEmpty == true) 'routeId': routeId!.trim(),
      if (tripId?.trim().isNotEmpty == true) 'tripId': tripId!.trim(),
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
}
