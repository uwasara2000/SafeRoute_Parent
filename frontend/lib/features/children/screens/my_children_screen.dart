import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/child_model.dart';
import '../services/children_service.dart';
import 'child_details_screen.dart';

/// Screen 1: My Children List Screen matching user's Image 1 with Delete feature
class MyChildrenScreen extends StatefulWidget {
  final List<ChildModel> initialChildren;
  final Function(ChildModel)? onSelectChild;

  const MyChildrenScreen({
    super.key,
    this.initialChildren = const [],
    this.onSelectChild,
  });

  @override
  State<MyChildrenScreen> createState() => _MyChildrenScreenState();
}

class _MyChildrenScreenState extends State<MyChildrenScreen> {
  final ChildrenService _childrenService = ChildrenService();

  void _confirmDeleteChild(ChildModel child) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Remove Child',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove ${child.name} from your account? This child will no longer be tracked on your dashboard.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _childrenService.deleteChild(child.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${child.name} was removed.'),
                      backgroundColor: const Color(0xFF1F2937),
                    ),
                  );
                }
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showAddChildDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final schoolCtrl = TextEditingController(text: 'Royal College');
    final gradeCtrl = TextEditingController(text: 'Grade 6A');
    final pickupCtrl = TextEditingController(text: 'Nawala Road stop');
    final dropOffCtrl = TextEditingController(text: 'Royal College main gate');
    final phoneCtrl = TextEditingController(text: '+94 77 555 0199');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Link New Child',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: nameCtrl,
                    label: 'Child Full Name',
                    hint: 'e.g. Amaya Silva or Dineth Silva',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter child name' : null,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: schoolCtrl,
                    label: 'School (e.g. Royal College, Ananda College)',
                    hint: 'School name',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: gradeCtrl,
                    label: 'Grade / Class',
                    hint: 'e.g. Grade 6A',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: pickupCtrl,
                    label: 'Pickup Location',
                    hint: 'e.g. Nawala Road stop',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: dropOffCtrl,
                    label: 'Drop-off Location',
                    hint: 'e.g. Royal College main gate',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: phoneCtrl,
                    label: 'Emergency Contact',
                    hint: 'e.g. +94 77 555 0199',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.of(ctx).pop();

                        await _childrenService.addChild(
                          name: nameCtrl.text.trim(),
                          school: schoolCtrl.text.trim(),
                          grade: gradeCtrl.text.trim(),
                          route: 'Route 08',
                          vehicleNumber: 'NB-4821',
                          pickupLocation: pickupCtrl.text.trim(),
                          dropOffLocation: dropOffCtrl.text.trim(),
                          emergencyContact: phoneCtrl.text.trim(),
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Child linked successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Link Child',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Children',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showAddChildDialog,
            child: const Text(
              '+ Link',
              style: TextStyle(
                color: Color(0xFF0D6B5D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChildModel>>(
          stream: _childrenService.getChildrenStream(),
          initialData: widget.initialChildren,
          builder: (context, snapshot) {
            final children = snapshot.data ?? [];

            if (children.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3EBE5).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.family_restroom_rounded,
                          size: 36,
                          color: Color(0xFF0D6B5D),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No Children Linked Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You have not linked any children yet. Tap below to link your children or load the demo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddChildDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Link Child Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6B5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _childrenService.seedTwoDemoChildren();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Loaded 2 children!'),
                                backgroundColor: AppColors.primaryTeal,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.bolt, size: 18, color: Color(0xFF0D6B5D)),
                        label: const Text('Add 2 Children (Amaya & Dineth)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D6B5D),
                          side: const BorderSide(color: Color(0xFF0D6B5D)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // List of Child Cards (e.g., 2 cards for 2 children)
                  ...children.map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildChildCard(child),
                      )),

                  const SizedBox(height: 10),

                  // "Student privacy protected" Info Box (Exact match to Image 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3EBE5).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF0D6B5D),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Student privacy protected',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D6B5D),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'New children require an invitation code and operator approval.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF6B7280),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Child Card matching Image 1 with trash/delete icon
  Widget _buildChildCard(ChildModel child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Avatar + Status Pill (ON BOARD) + Delete Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFD3EBE5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  child.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D6B5D),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3EBE5).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          child.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D6B5D),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete / Remove child button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFF9CA3AF), size: 22),
                    tooltip: 'Remove Child',
                    splashRadius: 18,
                    onPressed: () => _confirmDeleteChild(child),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Child Name
          Text(
            child.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 3),

          // School & Grade
          Text(
            '${child.school} · ${child.grade}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),

          // Route & Vehicle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child.route,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child.vehicleNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // "View Details" Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                if (widget.onSelectChild != null) {
                  widget.onSelectChild!(child);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChildDetailsScreen(
                      child: child,
                      onDelete: () {
                        _childrenService.deleteChild(child.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D6B5D), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D6B5D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
