import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/goal.dart';
import 'progress_ring.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.goalColors[goal.colorIndex % AppColors.goalColors.length];

    return GestureDetector(
      onTap: () => context.push('/goals/${goal.id}'),
      child: Container(
        width: 188,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              AppColors.card,
              AppColors.card,
            ],
            stops: const [0, 0.4, 1],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Ring row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    AppConstants.iconFromCode(goal.iconCode),
                    color: color,
                    size: 20,
                  ),
                ),
                ProgressRing(
                  progress: goal.progressPercent,
                  color: color,
                  size: 38,
                  strokeWidth: 4,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              goal.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Category
            Text(
              goal.category,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),

            const Spacer(),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 8),

            // Milestones count + due date
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 11, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  '${goal.completedMilestones}/${goal.totalMilestones}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (goal.targetDate != null)
                  Text(
                    AppDateUtils.formatRelative(goal.targetDate!),
                    style: TextStyle(
                      color: goal.isOverdue
                          ? AppColors.error
                          : AppColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            // Streak badge
            if (goal.currentStreak > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.currentStreak}d streak',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
