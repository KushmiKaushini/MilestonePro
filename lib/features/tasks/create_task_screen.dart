import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/milestone_repository.dart';
import '../../domain/usecases/milestone_usecases.dart';
import '../../shared/widgets/mp_button.dart';
import '../../shared/widgets/mp_text_field.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key, required this.milestoneId});
  final int milestoneId;

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _scheduledAt;
  bool _saving = false;
  String? _milestoneUid; // set via provider lookup

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final m = await ref
          .read(milestoneRepositoryProvider)
          ?.getById(widget.milestoneId);
      if (mounted && m != null) {
        setState(() => _milestoneUid = m.uid);
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
    if (_milestoneUid == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(milestoneUseCasesProvider).createTask(
            milestoneUid: _milestoneUid!,
            title: _titleController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            scheduledAt: _scheduledAt,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            MpTextField(
              controller: _titleController,
              label: 'Task Title',
              hint: 'e.g., Run 5km at an easy pace',
              prefixIcon: Icons.checklist_rounded,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            MpTextField(
              controller: _notesController,
              label: 'Notes (optional)',
              hint: 'Extra context or acceptance criteria…',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Optional scheduled date
            const Text(
              'Scheduled For (optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx)
                          .colorScheme
                          .copyWith(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _scheduledAt = picked);
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
                    const Icon(Icons.today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _scheduledAt == null
                          ? 'No scheduled date'
                          : '${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year}',
                      style: TextStyle(
                        color: _scheduledAt == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_scheduledAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _scheduledAt = null),
                        child: const Icon(Icons.clear,
                            size: 18, color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            MpButton(
              label: 'Add Task',
              onPressed: _milestoneUid != null ? _save : null,
              icon: Icons.add_rounded,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
