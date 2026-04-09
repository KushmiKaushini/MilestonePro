import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:milestone_pro/core/theme/app_colors.dart';
import 'package:milestone_pro/features/goals/domain/models/goal.dart';
import 'package:milestone_pro/features/goals/presentation/providers/goal_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalListAsync = ref.watch(goalListProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Welcome Back,',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Milestone Pro',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Cards (Wired)
              goalListAsync.when(
                data: (goals) {
                  final activeCount = goals.where((g) => !g.isCompleted).length;
                  final completedCount = goals.where((g) => g.isCompleted).length;
                  
                  return SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          FadeInLeft(
                            child: _buildSummaryCard(
                              context,
                              'Active Goals',
                              activeCount.toString(),
                              Icons.flag_rounded,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FadeInLeft(
                            delay: const Duration(milliseconds: 100),
                            child: _buildSummaryCard(
                              context,
                              'Completed',
                              completedCount.toString(),
                              Icons.check_circle_rounded,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FadeInLeft(
                            delay: const Duration(milliseconds: 200),
                            child: _buildSummaryCard(
                              context,
                              'Streak',
                              '0 Days', // Placeholder for streak logic
                              Icons.bolt_rounded,
                              AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
              ),

              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 12)),

              // Section Title
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: FadeInUp(
                    child: Text(
                      'Your Milestones',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),

              // Goals List (Wired)
              goalListAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(
                          child: Text(
                            'No goals yet. Tap + to start!',
                            style: GoogleFonts.outfit(color: AppColors.textTertiary),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = goals[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: 50 * index),
                            child: _buildGoalTile(context, goal, ref),
                          );
                        },
                        childCount: goals.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTile(BuildContext context, Goal goal, WidgetRef ref) {
    return Dismissible(
      key: Key(goal.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) {
        ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
      },
      child: GestureDetector(
        onTap: () {
          context.push('/details/${goal.id}');
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: goal.isCompleted 
                ? AppColors.success.withOpacity(0.2) 
                : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: goal.isCompleted,
                activeColor: AppColors.success,
                shape: const CircleBorder(),
                onChanged: (_) {
                  ref.read(goalNotifierProvider.notifier).toggleGoal(goal.id);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: goal.isCompleted 
                          ? AppColors.textTertiary 
                          : AppColors.textPrimary,
                        decoration: goal.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      ),
                    ),
                    Text(
                      goal.category.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    GoalCategory selectedCategory = GoalCategory.personal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Milestone',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What do you want to achieve?',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: GoalCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedCategory = cat),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newGoal = Goal()
                        ..title = titleController.text
                        ..description = ''
                        ..category = selectedCategory
                        ..createdAt = DateTime.now();
                      
                      ref.read(goalNotifierProvider.notifier).addGoal(newGoal);
                      Navigator.pop(context);
                    }
                  },
                  label: const Text('Create Goal'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
