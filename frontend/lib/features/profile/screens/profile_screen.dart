import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/parent_bottom_navigation.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../history/screens/journey_history_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../tracking/screens/live_tracking_screen.dart';
import '../../auth/screens/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  void _navigateToTab(int index) {
    if (index == 4) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final Widget destination = switch (index) {
      1 => const LiveTrackingScreen(),
      2 => const JourneyHistoryScreen(),
      3 => const AlertsScreen(),
      _ => const HomeScreen(),
    };
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign out. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to view your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true && mounted) await _signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Sign in to view your profile.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final profile =
                    snapshot.data?.data() ?? const <String, dynamic>{};
                final name = (profile['fullName'] as String?)?.trim();
                final displayName = name?.isNotEmpty == true
                    ? name!
                    : user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : 'Parent';
                final phone = (profile['phoneNumber'] as String?)?.trim();
                final initials = displayName
                    .split(RegExp(r'\s+'))
                    .where((part) => part.isNotEmpty)
                    .take(2)
                    .map((part) => part[0].toUpperCase())
                    .join();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFD3EBE5),
                      child: Text(
                        initials.isEmpty ? '?' : initials,
                        style: const TextStyle(
                          color: Color(0xFF0D6B5D),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (snapshot.hasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Some profile details could not be loaded.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(user.email ?? 'Not provided'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: const Text('Phone'),
                            subtitle: Text(
                              phone?.isNotEmpty == true
                                  ? phone!
                                  : user.phoneNumber ?? 'Not provided',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSigningOut ? null : _confirmSignOut,
                      icon: _isSigningOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: ParentBottomNavigation(
        currentIndex: 4,
        onTap: _navigateToTab,
      ),
    );
  }
}
