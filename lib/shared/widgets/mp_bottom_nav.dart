import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'mp_dock_nav.dart';

/// Persistent bottom navigation shell for the StatefulShellRoute.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // The page content
          Positioned.fill(
            child: navigationShell,
          ),
          
          // The floating glass dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MpDockNav(navigationShell: navigationShell),
          ),
        ],
      ),
    );
  }
}

