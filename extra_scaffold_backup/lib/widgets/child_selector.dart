import 'package:flutter/material.dart';
import 'package:saferoute_parent/models/child_model.dart';
import 'package:saferoute_parent/theme/app_theme.dart';

class ChildSelector extends StatelessWidget {
  final List<Child> children;
  final Child? selectedChild;
  final ValueChanged<Child>? onChanged;

  const ChildSelector({
    super.key,
    required this.children,
    this.selectedChild,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelected = selectedChild != null &&
        children.any((child) => child.id == selectedChild!.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: hasSelected ? selectedChild!.id : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: children.map((Child child) {
            return DropdownMenuItem<String>(
              value: child.id,
              child: Text(
                child.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? childId) {
            if (childId != null && onChanged != null) {
              final child = children.firstWhere(
                (c) => c.id == childId,
                orElse: () => Child(id: childId, name: ''),
              );
              onChanged!(child);
            }
          },
        ),
      ),
    );
  }
}
