import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/constants.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/milestone_repository.dart';
import '../../domain/usecases/goal_usecases.dart';
import '../../shared/widgets/empty_state.dart';
import '../dashboard/widgets/progress_ring.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalByIdProvider(goalId));

    return goalAsync.when(
      data: (goal) {
        if (goal == null) {
          return const Scaffold(
            body: Center(child: Text('Goal not found')),
          );
        }

        final color =
            AppColors.goalColors[goal.colorIndex % AppColors.goalColors.length];
        final milestonesAsync =
            ref.watch(milestonesForGoalProvider(goal.uid));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Hero App Bar ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.background,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    color: AppColors.card,
                    onSelected: (v) async {
                      if (v == 'edit') {
                        context.push('/goals/${goal.id}/edit');
                      } else if (v == 'archive') {
                        await ref
                            .read(goalRepositoryProvider)
                            ?.archive(goal.id);
                        if (context.mounted) context.pop();
                      } else if (v == 'delete') {
                        await ref
                            .read(goalUseCasesProvider)
                            .deleteGoal(goal.id);
                        if (context.mounted) context.pop();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'archive', child: Text('Archive')),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.25),
                          AppColors.background,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'goal_icon_${goal.id}',
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  AppConstants.iconFromCode(goal.iconCode),
                                  color: color,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.category,
                                    style: TextStyle(
                                        color: color.withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Hero(
                                    tag: 'goal_title_${goal.id}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        goal.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ProgressRing(
                              progress: goal.progressPercent,
                              color: color,
                              size: 52,
                              strokeWidth: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stats row ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Milestones',
                        value:
                            '${goal.completedMilestones}/${goal.totalMilestones}',
                        icon: Icons.flag_rounded,
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        label: 'Streak',
                        value: '${goal.currentStreak}d 🔥',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                      ),
                      if (goal.targetDate != null) ...[
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Due',
                          value: AppDateUtils.formatRelative(goal.targetDate!),
                          icon: Icons.calendar_today_rounded,
                          color: goal.isOverdue
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Milestones header ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Milestones',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context
                            .push('/goals/${goal.id}/milestones/create'),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Milestones list ──────────────────────────────────────────
              milestonesAsync.when(
                data: (milestones) {
                  if (milestones.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: EmptyState(
                          icon: Icons.flag_outlined,
                          title: 'No milestones',
                          subtitle:
                              'Add milestones to track progress toward this goal.',
                          action: () => context
                              .push('/goals/${goal.id}/milestones/create'),
                          actionLabel: 'Add Milestone',
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: milestones.length,
                    itemBuilder: (_, i) {
                      final m = milestones[i];
                      final pColor = AppColors.priorityColors[
                          m.priority.clamp(0, 3)];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: m.isCompleted
                              ? AppColors.surface
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: m.isCompleted
                                ? AppColors.divider
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Priority bar
                            Container(
                              width: 3,
                              height: 48,
                              decoration: BoxDecoration(
                                color: m.isCompleted
                                    ? AppColors.textHint
                                    : pColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: TextStyle(
                                      color: m.isCompleted
                                          ? AppColors.textHint
                                          : AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      decoration: m.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        AppDateUtils.formatRelative(m.dueDate),
                                        style: TextStyle(
                                          color: m.isOverdue
                                              ? AppColors.error
                                              : m.isDueSoon
                                                  ? AppColors.warning
                                                  : AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (m.totalTasks > 0) ...[
                                        const Text(' · ',
                                            style: TextStyle(
                                                color: AppColors.textHint,
                                                fontSize: 12)),
                                        Text(
                                          '${m.completedTasks}/${m.totalTasks} tasks',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (m.alarmEnabled)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.alarm_rounded,
                                    size: 14, color: AppColors.textHint),
                              ),
                            Icon(Icons.chevron_right_rounded,
                                size: 18, color: AppColors.textHint),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.push('/goals/${goal.id}/milestones/create'),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassFill.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
