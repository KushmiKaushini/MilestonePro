import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milestone_pro/core/theme/app_colors.dart';
import 'package:milestone_pro/features/goals/domain/models/goal.dart';
import 'package:milestone_pro/features/goals/presentation/providers/goal_provider.dart';

class GoalDetailsPage extends ConsumerWidget {
  final int goalId;
  const GoalDetailsPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalListAsync = ref.watch(goalListProvider);

    return goalListAsync.when(
      data: (goals) {
        final goal = goals.firstWhere((g) => g.id == goalId);
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  ref.read(goalNotifierProvider.notifier).deleteGoal(goalId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, AppColors.surface],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          goal.category.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        goal.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Progress Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildProgressCard(goal),
                    ),
                    
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Milestones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Milestones List (Wiring placeholder)
                    Expanded(
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Center(
                          child: Text(
                            'Milestones coming soon...',
                            style: GoogleFonts.outfit(color: AppColors.textTertiary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildProgressCard(Goal goal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                goal.isCompleted ? '100%' : '0%',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: goal.isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.isCompleted ? 1.0 : 0.0,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
