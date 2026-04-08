import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mp_button.dart';

/// Full-screen "unmissable" alarm overlay.
///
/// For [requiresPuzzle] = true: the user must solve a 2-digit math puzzle
/// before the alarm can be dismissed.
/// For [requiresPuzzle] = false: a simple Dismiss / Snooze pair is shown.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    required this.milestoneTitle,
    required this.milestoneUid,
    required this.requiresPuzzle,
  });

  final String milestoneTitle;
  final String milestoneUid;
  final bool requiresPuzzle;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  // ── Puzzle state ─────────────────────────────────────────────────────────
  late int _a;
  late int _b;
  late String _operator;
  late int _answer;
  final _controller = TextEditingController();
  String? _errorText;
  bool _solved = false;

  // ── Animation ────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Keep the screen on while alarm shows
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _generatePuzzle() {
    final rng = Random();
    _a = rng.nextInt(12) + 2; // 2–13
    _b = rng.nextInt(12) + 2;
    final ops = ['+', '×', '-'];
    _operator = ops[rng.nextInt(ops.length)];
    switch (_operator) {
      case '+':
        _answer = _a + _b;
      case '×':
        _answer = _a * _b;
      case '-':
        // Ensure positive result
        if (_b > _a) {
          final tmp = _a;
          _a = _b;
          _b = tmp;
        }
        _answer = _a - _b;
      default:
        _answer = _a + _b;
    }
  }

  void _checkAnswer() {
    final input = int.tryParse(_controller.text.trim());
    if (input == null) {
      setState(() => _errorText = 'Enter a number');
      return;
    }
    if (input == _answer) {
      setState(() {
        _solved = true;
        _errorText = null;
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 600), _dismiss);
    } else {
      setState(() => _errorText = 'Incorrect — try again!');
      HapticFeedback.vibrate();
      _controller.clear();
      // Regenerate puzzle after wrong answer
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _generatePuzzle();
            _errorText = null;
          });
        }
      });
    }
  }

  void _dismiss() {
    if (mounted) context.go('/dashboard');
  }

  void _snooze() {
    // Snooze 10 min — in production, reschedule via NotificationService
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snoozed for 10 minutes')),
    );
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Pulsing alarm icon ─────────────────────────────────────
              ScaleTransition(
                scale: _solved
                    ? const AlwaysStoppedAnimation(1.0)
                    : _pulseAnim,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _solved
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _solved ? AppColors.success : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _solved ? Icons.check_circle_rounded : Icons.alarm_rounded,
                    size: 48,
                    color: _solved ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────────────
              const Text(
                'Milestone Alarm',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.milestoneTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (widget.requiresPuzzle && !_solved) ...[
                // ── Math puzzle ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Solve to dismiss',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_a $_operator $_b = ?',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: '?',
                          errorText: _errorText,
                        ),
                        onSubmitted: (_) => _checkAnswer(),
                      ),
                      const SizedBox(height: 16),
                      MpButton(
                        label: 'Confirm Answer',
                        onPressed: _checkAnswer,
                        icon: Icons.check_rounded,
                      ),
                    ],
                  ),
                ),
              ] else if (!widget.requiresPuzzle) ...[
                // ── Simple dismiss/snooze ──────────────────────────────
                MpButton(
                  label: 'Dismiss',
                  onPressed: _dismiss,
                  icon: Icons.check_rounded,
                ),
                const SizedBox(height: 12),
                MpButton(
                  label: 'Snooze 10 min',
                  onPressed: _snooze,
                  variant: MpButtonVariant.secondary,
                  icon: Icons.snooze_rounded,
                ),
              ] else ...[
                // ── Solved feedback ────────────────────────────────────
                const Text(
                  '✅ Correct! Well done.',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
