/// Model representing parent profile data stored in Cloud Firestore
class ParentUserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // Always 'parent' for parent registration
  final DateTime createdAt;

  const ParentUserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.role = 'parent',
    required this.createdAt,
  });

  /// Convert model to Map for Firestore document storage.
  /// NOTE: Passwords must NEVER be stored in Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create model instance from Firestore document map
  factory ParentUserModel.fromMap(Map<String, dynamic> map, String docId) {
    return ParentUserModel(
      uid: docId,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      role: map['role'] as String? ?? 'parent',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

