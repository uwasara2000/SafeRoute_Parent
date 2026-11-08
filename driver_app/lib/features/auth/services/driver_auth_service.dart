import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Result object for driver authentication operations
class DriverAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? displayName;
  final String? role;
  final bool isApproved;
  final User? user;

  const DriverAuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.displayName,
    this.role,
    this.isApproved = true,
    this.user,
  });

  factory DriverAuthResult.success({
    required User user,
    String? displayName,
    String? role,
    bool isApproved = true,
  }) {
    return DriverAuthResult(
      isSuccess: true,
      user: user,
      displayName: displayName ?? user.displayName ?? 'Driver',
      role: role ?? 'driver',
      isApproved: isApproved,
    );
  }

  factory DriverAuthResult.failure(String errorMessage, {bool isApproved = true}) {
    return DriverAuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      isApproved: isApproved,
    );
  }
}

/// Service handling Driver & Attendant authentication and Firestore role authorization
class DriverAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password, verifying the role in Firestore
  Future<DriverAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return DriverAuthResult.failure('Authentication failed. No user found.');
      }

      // 1. Fetch user document from shared Firestore 'users' collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        final role = (data['role'] as String? ?? '').toLowerCase().trim();
        final isApproved = data['isApproved'] as bool? ?? true;
        final status = (data['status'] as String? ?? 'active').toLowerCase().trim();
        final fullName = data['fullName'] as String? ?? data['name'] as String? ?? user.displayName ?? 'Driver';

        // 2. Reject parents, students, or other client roles
        if (role == 'parent') {
          await _auth.signOut();
          return DriverAuthResult.failure(
            'Access Denied: This portal is reserved for authorized school bus drivers and attendants. Parents must use the Track My Kid Parent App.',
          );
        }

        // 3. Verify driver or attendant role
        if (role != 'driver' && role != 'attendant' && role != 'staff') {
          // If role is undefined or not authorized
          await _auth.signOut();
          return DriverAuthResult.failure(
            'Unauthorized role ($role). Please contact your Transport Operator Administrator to configure staff credentials.',
          );
        }

        // 4. Verify account approval / status
        if (!isApproved || status == 'pending_approval' || status == 'suspended') {
          await _auth.signOut();
          return DriverAuthResult.failure(
            'Your account is currently pending Transport Operator verification. Please wait for dispatch approval.',
            isApproved: false,
          );
        }

        return DriverAuthResult.success(
          user: user,
          displayName: fullName,
          role: role,
          isApproved: true,
        );
      } else {
        // Fallback for pre-existing driver/demo accounts before user document was indexed
        debugPrint('[DriverAuthService] No Firestore user doc for ${user.uid}. Checking email prefix.');
        final emailLower = (user.email ?? '').toLowerCase();
        if (emailLower.contains('driver') || emailLower.contains('attendant') || emailLower.contains('saferoute')) {
          return DriverAuthResult.success(
            user: user,
            displayName: user.displayName ?? 'Dilan Perera',
            role: 'driver',
          );
        }

        // If arbitrary email with no Firestore staff record, reject
        await _auth.signOut();
        return DriverAuthResult.failure(
          'No staff profile found for this account. Please register or ask your Transport Operator for an invitation.',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[DriverAuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      return DriverAuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      debugPrint('[DriverAuthService] Sign-in error: $e');
      return DriverAuthResult.failure(
        'An unexpected error occurred while signing in. Please check your network and try again.',
      );
    }
  }

  /// Register a new Driver / Attendant account with 'pending' authorization
  Future<DriverAuthResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String requestedRole, // 'driver' or 'attendant'
  }) async {
    try {
      // 1. Create account in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return DriverAuthResult.failure('Failed to create account.');
      }

      await user.updateDisplayName(fullName.trim());

      // 2. Persist in Firestore with isApproved = false (Pending Operator Admin approval)
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'role': requestedRole == 'Attendant' ? 'attendant' : 'driver',
        'isApproved': false, // Security: Never grant client-side instant approval
        'status': 'pending_approval',
        'assignedVehicle': null,
        'assignedRoute': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Immediately sign out to prevent unauthorized session access
      await _auth.signOut();

      return DriverAuthResult.success(
        user: user,
        displayName: fullName,
        role: requestedRole,
        isApproved: false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[DriverAuthService] Registration error: ${e.code} - ${e.message}');
      return DriverAuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      debugPrint('[DriverAuthService] Unexpected registration error: $e');
      return DriverAuthResult.failure(
        'Failed to submit registration. Please verify your details and try again.',
      );
    }
  }

  /// Send password reset link to user's email
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      debugPrint('[DriverAuthService] Password reset error: $e');
      // For security, do not leak whether email exists
      return true;
    }
  }

  /// Sign out current session
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account registered with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      case 'user-disabled':
        return 'This driver account has been suspended by the transport operator.';
      case 'invalid-email':
        return 'Please enter a valid operational email address.';
      case 'email-already-in-use':
        return 'An account with this email address already exists. Please sign in or reset your password.';
      case 'weak-password':
        return 'The chosen password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please verify your internet connection.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please wait a moment before trying again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
