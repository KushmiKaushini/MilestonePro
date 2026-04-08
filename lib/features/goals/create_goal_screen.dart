import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../domain/usecases/goal_usecases.dart';
import '../../shared/widgets/mp_button.dart';
import '../../shared/widgets/mp_text_field.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = AppConstants.goalCategories.first;
  int _selectedColorIndex = 0;
  int _selectedIconCode = AppConstants.goalIconCodes.first;
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(goalUseCasesProvider).createGoal(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            category: _selectedCategory,
            startDate: DateTime.now(),
            targetDate: _targetDate,
            colorIndex: _selectedColorIndex,
            iconCode: _selectedIconCode,
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
      appBar: AppBar(title: const Text('New Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Color & Icon picker ──────────────────────────────────────
            _SectionLabel(label: 'Appearance'),
            const SizedBox(height: 12),

            // Color swatches
            Wrap(
              spacing: 10,
              children: List.generate(AppColors.goalColors.length, (i) {
                final c = AppColors.goalColors[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColorIndex == i
                            ? Colors.white
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: _selectedColorIndex == i
                          ? [BoxShadow(color: c.withValues(alpha: 0.1), blurRadius: 8)]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Icon selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.goalIconCodes.asMap().entries.map((e) {
                  final isSelected = _selectedIconCode == e.value;
                  final color = AppColors.goalColors[_selectedColorIndex];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIconCode = e.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        AppConstants.iconFromCode(e.value),
                        color: isSelected ? color : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            // ── Title ────────────────────────────────────────────────────
            _SectionLabel(label: 'Goal Details'),
            const SizedBox(height: 12),
            MpTextField(
              controller: _titleController,
              label: 'Goal Title',
              hint: 'e.g., Run a half marathon',
              prefixIcon: Icons.flag_rounded,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            MpTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'What does achieving this goal mean to you?',
              maxLines: 3,
              minLines: 2,
            ),

            const SizedBox(height: 24),
            // ── Category ─────────────────────────────────────────────────
            _SectionLabel(label: 'Category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.goalCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            // ── Target date ───────────────────────────────────────────────
            _SectionLabel(label: 'Target Date (optional)'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
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
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
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
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _targetDate == null
                          ? 'No target date'
                          : _formatDate(_targetDate!),
                      style: TextStyle(
                        color: _targetDate == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _targetDate = null),
                        child: const Icon(Icons.clear,
                            size: 18, color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            MpButton(
              label: 'Create Goal',
              onPressed: _save,
              icon: Icons.check_rounded,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
