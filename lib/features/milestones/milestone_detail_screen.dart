import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/constants.dart';
import '../../data/repositories/milestone_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/usecases/milestone_usecases.dart';
import '../../shared/widgets/empty_state.dart';

class MilestoneDetailScreen extends ConsumerWidget {
  const MilestoneDetailScreen({super.key, required this.milestoneId});
  final int milestoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneByIdProvider(milestoneId));

    return milestoneAsync.when(
      data: (milestone) {
        if (milestone == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }

        final tasksAsync =
            ref.watch(tasksForMilestoneProvider(milestone.uid));
        final priorityColor =
            AppColors.priorityColors[milestone.priority.clamp(0, 3)];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Milestone'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                color: AppColors.card,
                onSelected: (v) async {
                  if (v == 'complete') {
                    await ref
                        .read(milestoneUseCasesProvider)
                        .completeMilestone(milestone.id);
                  } else if (v == 'delete') {
                    await ref
                        .read(milestoneUseCasesProvider)
                        .deleteMilestone(milestone.id);
                    if (context.mounted) context.pop();
                  }
                },
                itemBuilder: (_) => [
                  if (!milestone.isCompleted)
                    const PopupMenuItem(
                        value: 'complete', child: Text('Mark Complete')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Milestone card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppConstants.priorityLabels[
                                milestone.priority.clamp(0, 3)],
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (milestone.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✓ Completed',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      milestone.title,
                      style: TextStyle(
                        color: milestone.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        decoration: milestone.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (milestone.notes != null &&
                        milestone.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        milestone.notes!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Due date
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 16,
                            color: milestone.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Due ${AppDateUtils.formatDate(milestone.dueDate)}',
                          style: TextStyle(
                            color: milestone.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (milestone.alarmEnabled) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.alarm_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            milestone.alarmDateTime != null
                                ? AppDateUtils.formatTime(
                                    milestone.alarmDateTime!)
                                : 'Alarm set',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Task progress bar
                    if (milestone.totalTasks > 0) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            '${milestone.completedTasks}/${milestone.totalTasks} tasks',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(milestone.taskProgress * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: milestone.taskProgress,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tasks section ──────────────────────────────────────────
              Row(
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push(
                        '/milestones/${milestone.id}/tasks/create'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.checklist_rounded,
                      title: 'No tasks yet',
                      subtitle:
                          'Break this milestone into small, actionable tasks.',
                      action: () => context.push(
                          '/milestones/${milestone.id}/tasks/create'),
                      actionLabel: 'Add Task',
                    );
                  }
                  return Column(
                    children: tasks.map((task) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(taskRepositoryProvider)
                                  ?.toggle(task.id);
                              await ref
                                  .read(milestoneUseCasesProvider)
                                  .refreshMilestoneTaskProgress(
                                      milestone.uid);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: task.isCompleted
                                    ? AppColors.success
                                    : Colors.transparent,
                                border: Border.all(
                                  color: task.isCompleted
                                      ? AppColors.success
                                      : AppColors.border,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: task.isCompleted
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                              fontSize: 14,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: task.scheduledAt != null
                              ? Text(
                                  AppDateUtils.formatRelative(
                                      task.scheduledAt!),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.push('/milestones/${milestone.id}/tasks/create'),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
