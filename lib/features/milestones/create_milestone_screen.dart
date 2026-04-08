import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../data/repositories/goal_repository.dart';
import '../../domain/usecases/milestone_usecases.dart';
import '../../features/notifications/alarm_service.dart';
import '../../shared/widgets/mp_button.dart';
import '../../shared/widgets/mp_text_field.dart';

class CreateMilestoneScreen extends ConsumerStatefulWidget {
  const CreateMilestoneScreen({super.key, required this.goalId});
  final int goalId;

  @override
  ConsumerState<CreateMilestoneScreen> createState() =>
      _CreateMilestoneScreenState();
}

class _CreateMilestoneScreenState
    extends ConsumerState<CreateMilestoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  int _priority = 1;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _alarmEnabled = false;
  DateTime? _alarmDateTime;
  bool _requiresPuzzle = false;
  bool _saving = false;

  // We need the goalUid from the Goal for the use-case
  String? _goalUid;

  @override
  void initState() {
    super.initState();
    // Look up the Goal's UUID from its Isar integer id so we can pass it
    // to the milestone use-case (which uses string-based foreign keys).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final goal =
          await ref.read(goalRepositoryProvider)?.getById(widget.goalId);
      if (mounted && goal != null) {
        setState(() => _goalUid = goal.uid);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_goalUid == null) return;

    setState(() => _saving = true);
    try {
      final milestone = await ref
          .read(milestoneUseCasesProvider)
          .createMilestone(
            goalUid: _goalUid!,
            title: _titleController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            dueDate: _dueDate,
            priority: _priority,
            alarmEnabled: _alarmEnabled,
            alarmDateTime: _alarmDateTime,
            requiresPuzzleDismiss: _requiresPuzzle,
          );

      // Schedule alarm if enabled
      if (_alarmEnabled && _alarmDateTime != null) {
        await AlarmService.instance.scheduleAlarm(
          id: milestone.id,
          alarmTime: _alarmDateTime!,
          milestoneTitle: milestone.title,
          milestoneUid: milestone.uid,
          requiresPuzzle: _requiresPuzzle,
        );
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Milestone')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            MpTextField(
              controller: _titleController,
              label: 'Milestone Title',
              hint: 'e.g., Complete Week 1 Training Plan',
              prefixIcon: Icons.flag_outlined,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            MpTextField(
              controller: _notesController,
              label: 'Notes (optional)',
              hint: 'Any context or success criteria…',
              maxLines: 3,
              minLines: 2,
            ),

            const SizedBox(height: 24),
            _SectionLabel('Priority'),
            const SizedBox(height: 12),
            Row(
              children: List.generate(AppConstants.priorityLabels.length, (i) {
                final isSelected = _priority == i;
                final color = AppColors.priorityColors[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.circle, size: 8, color: color),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.priorityLabels[i],
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textHint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),
            _SectionLabel('Due Date'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx)
                          .colorScheme
                          .copyWith(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _SectionLabel('Alarm'),
            const SizedBox(height: 12),

            // Alarm toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alarm_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enable Alarm',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            Text('Schedule an unmissable reminder',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _alarmEnabled,
                        onChanged: (v) => setState(() => _alarmEnabled = v),
                      ),
                    ],
                  ),
                  if (_alarmEnabled) ...[
                    const Divider(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: _dueDate,
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: Theme.of(ctx)
                                  .colorScheme
                                  .copyWith(primary: AppColors.primary),
                            ),
                            child: child!,
                          ),
                        );
                        if (date == null || !context.mounted) return;
                        
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        
                        if (time == null || !context.mounted) return;
                        setState(() {
                          _alarmDateTime = DateTime(
                              date.year, date.month, date.day,
                              time.hour, time.minute);
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            _alarmDateTime == null
                                ? 'Set alarm time'
                                : '${_alarmDateTime!.day}/${_alarmDateTime!.month}/${_alarmDateTime!.year} at ${_alarmDateTime!.hour.toString().padLeft(2, '0')}:${_alarmDateTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: _alarmDateTime == null
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Require Math Puzzle to Dismiss',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  'Solve a quick equation to prove you\'re awake',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _requiresPuzzle,
                          onChanged: (v) =>
                              setState(() => _requiresPuzzle = v),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            MpButton(
              label: 'Create Milestone',
              onPressed: _goalUid != null ? _save : null,
              icon: Icons.flag_rounded,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}



class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
