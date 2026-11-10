import 'package:flutter/material.dart';
import 'package:saferoute_parent/services/journey_service.dart';
import 'package:saferoute_parent/theme/app_theme.dart';

class JourneyFilterTabs extends StatelessWidget {
  final JourneyFilter selectedFilter;
  final ValueChanged<JourneyFilter> onFilterChanged;

  const JourneyFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  Widget _buildTab({
    required JourneyFilter filter,
    required String label,
  }) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(
                    color: AppColors.primary,
                    width: 2.0,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(
          filter: JourneyFilter.all,
          label: 'All',
        ),
        _buildTab(
          filter: JourneyFilter.morning,
          label: 'Morning',
        ),
        _buildTab(
          filter: JourneyFilter.afternoon,
          label: 'Afternoon',
        ),
      ],
    );
  }
}
