import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/analytics_usecases.dart';
import 'widgets/completion_heatmap.dart';
import 'widgets/velocity_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
          children: [
            // ── Stat cards row ──────────────────────────────────────────
            FadeInDown(
              child: Row(
                children: [
                  _BigStatCard(
                    value: '${data.completedMilestones}',
                    label: 'Milestones\nCompleted',
                    icon: Icons.flag_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _BigStatCard(
                    value: '${data.longestStreak}d',
                    label: 'Longest\nStreak',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  _BigStatCard(
                    value:
                        '${(data.completionRate * 100).round()}%',
                    label: 'Completion\nRate',
                    icon: Icons.pie_chart_rounded,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Velocity chart ──────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _Section(
                title: 'Milestone Velocity',
                subtitle: 'Completions per week · last 12 weeks',
                child: SizedBox(
                  height: 180,
                  child: data.velocityByWeek.every((v) => v == 0)
                      ? const Center(
                          child: Text(
                            'Complete milestones to see your velocity',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        )
                      : VelocityChart(weeklyData: data.velocityByWeek),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Smart scheduling suggestion ─────────────────────────────
            if (data.completedMilestones > 0)
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🧠', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Smart Scheduling',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You\'re most productive around ${_formatHour(data.suggestedPeakHour)}. '
                              'Set your milestone alarms then for best results.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ── Activity heatmap ────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _Section(
                title: 'Activity Heatmap',
                subtitle: 'Last 12 weeks',
                child: data.completedMilestones == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No activity to display yet',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ),
                      )
                    : CompletionHeatmap(
                        activityByDay: _buildActivityMap(data),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Category breakdown ──────────────────────────────────────
            if (data.categoryBreakdown.isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: _Section(
                  title: 'Goals by Category',
                  subtitle: '${data.totalGoals} active goals',
                  child: _CategoryBreakdownList(
                    breakdown: data.categoryBreakdown,
                    total: data.totalGoals,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ── Overview numbers ────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _Section(
                title: 'Summary',
                child: Column(
                  children: [
                    _SummaryRow(
                        label: 'Total Goals',
                        value: '${data.totalGoals}'),
                    _SummaryRow(
                        label: 'Goals Completed',
                        value: '${data.completedGoals}'),
                    _SummaryRow(
                        label: 'Total Milestones',
                        value: '${data.totalMilestones}'),
                    _SummaryRow(
                        label: 'Current Top Streak',
                        value: '${data.currentStreak} days 🔥'),
                    _SummaryRow(
                        label: 'All-Time Best Streak',
                        value: '${data.longestStreak} days'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '$h:00 $period';
  }

  Map<DateTime, int> _buildActivityMap(AnalyticsData data) {
    // We don't have completedAt stored in analytics directly — this is 
    // a placeholder that the CompletionHeatmap can consume once we 
    // pass actual completedAt dates through from the repository.
    return {};
  }
}



// ── UI components ──────────────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({
    required this.breakdown,
    required this.total,
  });

  final Map<String, int> breakdown;
  final int total;

  @override
  Widget build(BuildContext context) {
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = AppColors.goalColors;

    return Column(
      children: sorted.asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final pct = total == 0 ? 0.0 : cat.value / total;
        final color = colors[i % colors.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cat.key,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${cat.value}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
