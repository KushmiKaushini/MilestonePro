import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/goals/goal_list_screen.dart';
import '../../features/goals/goal_detail_screen.dart';
import '../../features/goals/create_goal_screen.dart';
import '../../features/goals/edit_goal_screen.dart';
import '../../features/milestones/milestone_detail_screen.dart';
import '../../features/milestones/create_milestone_screen.dart';
import '../../features/tasks/create_task_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/notifications/notification_screen.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/mp_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingAsync = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      // Wait for onboarding status to load
      return onboardingAsync.when(
        data: (completed) {
          final isLoggingIn = state.matchedLocation == '/onboarding';
          if (!completed) return '/onboarding';
          if (isLoggingIn) return '/dashboard';
          return null;
        },
        loading: () => null, // Stay where we are until loaded
        error: (_, _) => null,
      );
    },
    routes: [
      // ── Standalone routes (no bottom nav) ──────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (ctx, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/alarm',
        builder: (ctx, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return NotificationScreen(
            milestoneTitle: extras['title'] as String? ?? 'Milestone',
            milestoneUid: extras['uid'] as String? ?? '',
            requiresPuzzle: extras['puzzle'] as bool? ?? false,
          );
        },
      ),

      // ── Shell routes (persistent bottom nav) ───────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => MainScaffold(navigationShell: shell),
        branches: [
          // Tab 0 — Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (ctx, _) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1 — Goals (with nested routes)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                builder: (ctx, _) => const GoalListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (ctx, _) => const CreateGoalScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 — Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (ctx, _) => const AnalyticsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen push routes (outside shell) ────────────────────────
      GoRoute(
        path: '/goals/:goalId',
        builder: (ctx, state) => GoalDetailScreen(
          goalId: int.parse(state.pathParameters['goalId']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (ctx, state) => EditGoalScreen(
              goalId: int.parse(state.pathParameters['goalId']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/goals/:goalId/milestones/create',
        builder: (ctx, state) {
          final goalId = int.parse(state.pathParameters['goalId']!);
          return CreateMilestoneScreen(goalId: goalId);
        },
      ),
      GoRoute(
        path: '/milestones/:milestoneId',
        builder: (ctx, state) => MilestoneDetailScreen(
          milestoneId: int.parse(state.pathParameters['milestoneId']!),
        ),
      ),
      GoRoute(
        path: '/milestones/:milestoneId/tasks/create',
        builder: (ctx, state) {
          return CreateTaskScreen(
            milestoneId: int.parse(state.pathParameters['milestoneId']!),
          );
        },
      ),
    ],
  );
});
