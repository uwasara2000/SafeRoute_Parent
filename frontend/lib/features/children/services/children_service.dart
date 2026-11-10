import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/child_model.dart';

/// Service to manage children in Cloud Firestore
class ChildrenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of children for the logged-in parent.
  Stream<List<ChildModel>> getChildrenStream() {
    final uid = currentUserId;
    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChildModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Delete a child document from Firestore
  Future<void> deleteChild(String childId) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('No authenticated parent logged in.');
    if (childId.isEmpty) throw ArgumentError.value(childId, 'childId');

    final childReference = _firestore.collection('children').doc(childId);
    final child = await childReference.get();
    if (!child.exists || child.data()?['parentId'] != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'This child is not linked to the signed-in parent.',
      );
    }

    await childReference.delete();
  }

  /// Update child's registered pickup & drop-off locations in Cloud Firestore
  Future<void> updateChildLocations({
    required String childId,
    required String pickupLocation,
    required String dropOffLocation,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('No authenticated parent logged in.');
    if (childId.isEmpty) throw ArgumentError.value(childId, 'childId');

    final childReference = _firestore.collection('children').doc(childId);
    final child = await childReference.get();
    if (!child.exists || child.data()?['parentId'] != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'This child is not linked to the signed-in parent.',
      );
    }

    await childReference.update({
      'pickupLocation': pickupLocation.trim(),
      'dropOffLocation': dropOffLocation.trim(),
      'lastKnownLocation':
          'Pickup: ${pickupLocation.trim()} · School: ${dropOffLocation.trim()}',
    });
  }

  /// Add a new child to Firestore
  Future<void> addChild({
    required String name,
    required String school,
    required String grade,
    String? route,
    String? routeId,
    String? tripId,
    required String vehicleNumber,
    required String pickupLocation,
    required String dropOffLocation,
    required String emergencyContact,
    String? transportOperator,
    String? authorizedGuardians,
    String? pickupTime,
    String? dropOffTime,
    String? eta,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('No authenticated parent logged in.');

    final child = ChildModel(
      id: '',
      parentId: uid,
      name: name.trim(),
      school: school.trim(),
      grade: grade.trim(),
      route: route?.trim() ?? '',
      routeId: routeId,
      tripId: tripId,
      vehicleNumber: vehicleNumber.trim(),
      status: 'Not yet linked',
      eta: eta?.trim() ?? '',
      lastKnownLocation: 'No trip updates yet',
      schoolInfo: school.trim(),
      pickupLocation: pickupLocation.trim(),
      pickupTime: pickupTime?.trim() ?? '',
      dropOffLocation: dropOffLocation.trim(),
      dropOffTime: dropOffTime?.trim() ?? '',
      transportOperator: transportOperator?.trim() ?? '',
      authorizedGuardians: authorizedGuardians?.trim() ?? '',
      emergencyContact: emergencyContact.trim(),
      initials: _computeInitials(name.trim()),
    );

    await _firestore.collection('children').add(child.toMap());
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
