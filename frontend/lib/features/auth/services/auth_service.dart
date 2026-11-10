import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/parent_user_model.dart';

/// Result object returned by authentication operations
class AuthResponse {
  final bool isSuccess;
  final String? errorMessage;
  final ParentUserModel? user;

  const AuthResponse({required this.isSuccess, this.errorMessage, this.user});

  factory AuthResponse.success(ParentUserModel user) {
    return AuthResponse(isSuccess: true, user: user);
  }

  factory AuthResponse.failure(String errorMessage) {
    return AuthResponse(isSuccess: false, errorMessage: errorMessage);
  }
}

/// Authentication and Firestore service for Parent Registration
///
/// Handles account creation via Firebase Authentication and parent profile
/// persistence in Cloud Firestore under the 'users' collection.
class AuthService {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _injectedAuth = auth,
      _injectedFirestore = firestore;

  FirebaseAuth get auth => _injectedAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  /// Registers a new parent account.
  Future<AuthResponse> registerParent({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    User? createdUser;
    try {
      // 1. Create account in Firebase Authentication
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = userCredential.user;

      final uid = createdUser?.uid;
      if (uid == null) {
        return AuthResponse.failure('Failed to obtain user ID from Firebase.');
      }

      // 2. Set Firebase Auth display name
      await createdUser!.updateDisplayName(fullName.trim());

      // 3. Prepare parent profile for Cloud Firestore
      final parentProfile = ParentUserModel(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        role: 'parent',
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore under `users/{uid}` using UID as the document ID
      await firestore.collection('users').doc(uid).set(parentProfile.toMap());

      return AuthResponse.success(parentProfile);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException: ${e.code}');
      await _rollbackRegistration(createdUser);
      return AuthResponse.failure(_handleFirebaseAuthException(e));
    } on FirebaseException catch (e) {
      debugPrint('[AuthService] FirebaseException: ${e.code}');
      await _rollbackRegistration(createdUser);
      return AuthResponse.failure(
        'Unable to save your account details. Please try again.',
      );
    } catch (e) {
      debugPrint(
        '[AuthService] Unexpected registration error: ${e.runtimeType}',
      );
      await _rollbackRegistration(createdUser);
      return AuthResponse.failure(
        'An unexpected error occurred during registration. Please try again.',
      );
    }
  }

  Future<void> _rollbackRegistration(User? user) async {
    if (user == null) return;

    try {
      await firestore.collection('users').doc(user.uid).delete();
    } on FirebaseException catch (error) {
      debugPrint('[AuthService] Profile cleanup failed: ${error.code}');
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      debugPrint('[AuthService] Account cleanup failed: ${error.code}');
    }

    try {
      await auth.signOut();
    } on FirebaseAuthException catch (error) {
      debugPrint(
        '[AuthService] Sign-out after registration failure failed: ${error.code}',
      );
    }
  }

  /// Maps Firebase exceptions to user-friendly error messages
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered. Please log in instead.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'operation-not-allowed':
        return 'Email & Password sign-in is not enabled in Firebase Console.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 8 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ??
            'Authentication failed (${e.code}). Please try again.';
    }
  }
}
