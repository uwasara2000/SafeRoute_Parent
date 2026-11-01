import 'package:flutter/foundation.dart';
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
    if (uid == null) throw Exception('No authenticated parent logged in.');
    if (childId.isEmpty) return;

    await _firestore.collection('children').doc(childId).delete();
    debugPrint('[ChildrenService] Deleted child: $childId for parent: $uid');
  }

  /// Convenience method to seed demo two children for testing Sri Lanka dual-school tracking
  Future<void> seedTwoDemoChildren() async {
    final uid = currentUserId;
    if (uid == null) return;

    final child1 = ChildModel.defaultAmaya(uid);
    final child2 = ChildModel.defaultSecondChild(uid);
    await _firestore.collection('children').add(child1.toMap());
    await _firestore.collection('children').add(child2.toMap());
    debugPrint('[ChildrenService] Seeded 2 demo children for parent: $uid');
  }

  /// Add a new child to Firestore
  Future<void> addChild({
    required String name,
    required String school,
    required String grade,
    required String route,
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
    if (uid == null) throw Exception('No authenticated parent logged in.');

    final child = ChildModel(
      id: '',
      parentId: uid,
      name: name.trim(),
      school: school.trim(),
      grade: grade.trim(),
      route: route.trim().isEmpty ? 'Route 08' : route.trim(),
      vehicleNumber: vehicleNumber.trim().isEmpty ? 'NB-4821' : vehicleNumber.trim(),
      status: 'ON BOARD',
      eta: eta?.trim().isNotEmpty == true ? eta!.trim() : 'ETA 7:48 AM',
      lastKnownLocation: 'En route to ${school.trim()} · updated now',
      schoolInfo: '${school.trim()}, Colombo',
      pickupLocation: pickupLocation.trim().isEmpty ? 'Home stop' : pickupLocation.trim(),
      pickupTime: pickupTime?.trim().isNotEmpty == true ? pickupTime!.trim() : '7:15 AM',
      dropOffLocation: dropOffLocation.trim().isEmpty ? '${school.trim()} main gate' : dropOffLocation.trim(),
      dropOffTime: dropOffTime?.trim().isNotEmpty == true ? dropOffTime!.trim() : '7:55 AM',
      transportOperator: transportOperator?.trim().isNotEmpty == true ? transportOperator!.trim() : 'City School Transport',
      authorizedGuardians: authorizedGuardians?.trim().isNotEmpty == true ? authorizedGuardians!.trim() : 'Authorized Parent',
      emergencyContact: emergencyContact.trim().isEmpty ? '+94 77 555 0199' : emergencyContact.trim(),
      initials: _computeInitials(name.trim()),
    );

    await _firestore.collection('children').add(child.toMap());
    debugPrint('[ChildrenService] Added child: ${child.name} for parent: $uid');
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
