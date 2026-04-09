import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/goal.dart';
import 'progress_ring.dart';
import '../../../shared/widgets/mp_glass_card.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.goalColors[goal.colorIndex % AppColors.goalColors.length];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: MpGlassCard(
        onTap: () => context.push('/goals/${goal.id}'),
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        borderColor: color,
        borderOpacity: 0.3,
        fillOpacity: 0.1,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Ring row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'goal_icon_${goal.id}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      AppConstants.iconFromCode(goal.iconCode),
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
                ProgressRing(
                  progress: goal.progressPercent,
                  color: color,
                  size: 44,
                  strokeWidth: 5,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'goal_title_${goal.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    goal.category,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progressPercent,
                backgroundColor: AppColors.border.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FooterItem(
                  icon: Icons.flag_rounded,
                  text: '${goal.completedMilestones}/${goal.totalMilestones}',
                ),
                if (goal.targetDate != null)
                  _FooterItem(
                    icon: Icons.calendar_today_rounded,
                    text: AppDateUtils.formatRelative(goal.targetDate!),
                    isError: goal.isOverdue,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 11,
          color: isError ? AppColors.error : AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isError ? AppColors.error : AppColors.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
