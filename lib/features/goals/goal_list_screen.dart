import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/constants.dart';
import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../shared/widgets/empty_state.dart';

class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/goals/create'),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'No goals yet',
              subtitle:
                  'Define your North Star. Create your first goal and start breaking it down.',
              action: () => context.push('/goals/create'),
              actionLabel: 'Create Goal',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
            itemCount: goals.length,
            itemBuilder: (_, i) => FadeInUp(
              delay: Duration(milliseconds: i * 50),
              child: _GoalListTile(goal: goals[i]),
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading goals: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'goals_fab',
        onPressed: () => context.push('/goals/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _GoalListTile extends StatelessWidget {
  const _GoalListTile({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.goalColors[goal.colorIndex % AppColors.goalColors.length];

    return GestureDetector(
      onTap: () => context.push('/goals/${goal.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppConstants.iconFromCode(goal.iconCode),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (goal.isPinned)
                        const Icon(Icons.push_pin_rounded,
                            size: 14, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        goal.category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (goal.targetDate != null) ...[
                        const SizedBox(width: 8),
                        const Text(' · ',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                        Text(
                          AppDateUtils.formatRelative(goal.targetDate!),
                          style: TextStyle(
                            color: goal.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: goal.progressPercent,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(goal.progressPercent * 100).round()}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
