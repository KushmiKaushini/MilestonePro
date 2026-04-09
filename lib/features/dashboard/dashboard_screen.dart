import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/milestone_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../dashboard/widgets/goal_card.dart';
import '../dashboard/widgets/streak_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bokehController;

  @override
  void initState() {
    super.initState();
    _bokehController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bokehController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final upcomingAsync = ref.watch(upcomingMilestonesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Animated Background ──────────────────────────────────────────
          _BokehBackground(controller: _bokehController),

          // ── Dashboard Content ────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Top Spacing ──────────────────────────────────────────────
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeInDown(duration: const Duration(milliseconds: 800), child: _Header()),
              ),

              // ── Streak Banner ────────────────────────────────────────────
              goalsAsync.when(
                data: (goals) {
                  final streakGoal = goals
                      .where((g) => g.currentStreak > 0)
                      .fold<dynamic>(
                        null,
                        (prev, g) => prev == null || g.currentStreak > prev.currentStreak ? g : prev,
                      );
                  if (streakGoal == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: StreakBanner(
                          streakDays: streakGoal.currentStreak as int,
                          goalTitle: streakGoal.title as String,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              // ── Section: Active Goals ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Text(
                        'Active Goals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/goals'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyState(
                          icon: Icons.flag_outlined,
                          title: 'No goals yet',
                          subtitle: 'Your journey starts with a single step.',
                          action: () => context.push('/goals/create'),
                          actionLabel: 'Initialize Goal',
                        ),
                      ),
                    );
                  }
                  // Horizontal "Bento" style scroll
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: goals.length,
                        itemBuilder: (_, i) => FadeInRight(
                          delay: Duration(milliseconds: 200 + (i * 100)),
                          duration: const Duration(milliseconds: 600),
                          child: GoalCard(goal: goals[i]),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $e')),
                ),
              ),

              // ── Section: Upcoming ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Upcoming Milestones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
              ),

              upcomingAsync.when(
                data: (milestones) {
                  if (milestones.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          'All clear! Add milestones to track your progress.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: milestones.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final m = milestones[i];
                        final priorityColor = AppColors.priorityColors[m.priority.clamp(0, 3)];
                        return FadeInUp(
                          delay: Duration(milliseconds: 400 + (i * 80)),
                          child: _MilestoneItem(
                            title: m.title,
                            date: AppDateUtils.formatRelative(m.dueDate),
                            priorityColor: priorityColor,
                            isOverdue: m.isOverdue,
                            isDueSoon: m.isDueSoon,
                            alarmEnabled: m.alarmEnabled,
                            onTap: () => context.push('/milestones/${m.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50), // Adjust for Dock
        child: FloatingActionButton.extended(
          heroTag: 'dashboard_fab',
          onPressed: () => context.push('/goals/create'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Goal'),
        ),
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  const _MilestoneItem({
    required this.title,
    required this.date,
    required this.priorityColor,
    required this.isOverdue,
    required this.isDueSoon,
    required this.alarmEnabled,
    required this.onTap,
  });

  final String title;
  final String date;
  final Color priorityColor;
  final bool isOverdue;
  final bool isDueSoon;
  final bool alarmEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 48,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: priorityColor.withValues(alpha: 0.4), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: isOverdue
                              ? AppColors.error
                              : isDueSoon
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (alarmEnabled) ...[
                  Icon(Icons.alarm_rounded, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BokehBackground extends StatelessWidget {
  const _BokehBackground({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BokehPainter(progress: controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _BokehPainter extends CustomPainter {
  _BokehPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    void drawBlob(Offset center, double radius, Color color) {
      paint.color = color.withValues(alpha: 0.15);
      canvas.drawCircle(center, radius, paint);
    }

    // Blob 1: Violet
    final x1 = size.width * (0.2 + 0.1 * progress);
    final y1 = size.height * (0.3 + 0.05 * progress);
    drawBlob(Offset(x1, y1), 180, AppColors.primary);

    // Blob 2: Cyan
    final x2 = size.width * (0.8 - 0.1 * progress);
    final y2 = size.height * (0.6 + 0.1 * progress);
    drawBlob(Offset(x2, y2), 220, AppColors.secondary);

    // Blob 3: Magenta
    final x3 = size.width * (0.4 + 0.2 * progress);
    final y3 = size.height * (0.8 - 0.1 * progress);
    drawBlob(Offset(x3, y3), 150, AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant _BokehPainter oldDelegate) => true;
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.greeting().toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Milestone Pro',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.glassFill.withValues(alpha: 0.1),
              side: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.1)),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

