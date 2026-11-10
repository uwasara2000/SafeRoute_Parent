import 'package:flutter/material.dart';
import 'package:saferoute_parent/models/journey_model.dart';
import 'package:saferoute_parent/theme/app_theme.dart';
import 'package:saferoute_parent/utils/date_formatter.dart';
import 'package:saferoute_parent/widgets/status_badge.dart';

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneyCard({
    super.key,
    required this.journey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = journey.status == JourneyStatus.cancelled;
    final formattedDate = formatJourneyDate(journey.date);
    final route = journey.routeName;
    final subtitle1 = (route != null && route.isNotEmpty)
        ? '$formattedDate · $route'
        : formattedDate;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCancelled
                      ? AppColors.statusCancelled.withValues(alpha: 0.1)
                      : AppColors.primaryLight,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCancelled
                      ? Icons.warning_amber_rounded
                      : Icons.directions_bus_outlined,
                  size: 24,
                  color: isCancelled
                      ? AppColors.statusCancelled
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.journeyTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (journey.startTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        formatTimeRange(journey.startTime, journey.endTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      const Text(
                        '—',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                    if (journey.boardingTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Boarded: ${formatTime(journey.boardingTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (journey.dropOffTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Dropped off: ${formatTime(journey.dropOffTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (journey.statusMessage != null &&
                        journey.statusMessage!.isNotEmpty &&
                        journey.status == JourneyStatus.inProgress) ...[
                      const SizedBox(height: 2),
                      Text(
                        journey.statusMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (journey.lastUpdated != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Updated ${formatLastUpdated(journey.lastUpdated)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: journey.status),
            ],
          ),
        ),
      ),
    );
  }
}
