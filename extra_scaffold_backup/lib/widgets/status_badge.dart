import 'package:flutter/material.dart';
import 'package:saferoute_parent/models/journey_model.dart';
import 'package:saferoute_parent/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final JourneyStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.statusCompleted;
      case JourneyStatus.cancelled:
        return AppColors.statusCancelled;
      case JourneyStatus.inProgress:
        return AppColors.statusInProgress;
      case JourneyStatus.scheduled:
      case JourneyStatus.unknown:
        return AppColors.textHint;
    }
  }

  String _getStatusText() {
    switch (status) {
      case JourneyStatus.completed:
        return 'Completed';
      case JourneyStatus.cancelled:
        return 'Cancelled';
      case JourneyStatus.inProgress:
        return 'In Progress';
      case JourneyStatus.scheduled:
        return 'Scheduled';
      case JourneyStatus.unknown:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = _getStatusText();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: color,
        ),
      ],
    );
  }
}
