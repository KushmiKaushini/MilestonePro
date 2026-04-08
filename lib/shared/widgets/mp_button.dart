import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MpButtonVariant { primary, secondary, ghost, danger }

class MpButton extends StatefulWidget {
  const MpButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MpButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final MpButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  State<MpButton> createState() => _MpButtonState();
}

class _MpButtonState extends State<MpButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    final child = widget.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: const TextStyle(letterSpacing: 0.3),
              ),
            ],
          );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: isEnabled ? _onTapDown : null,
        onTapUp: isEnabled ? _onTapUp : null,
        onTapCancel: isEnabled ? _onTapCancel : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.isExpanded ? double.infinity : null,
            decoration: widget.variant == MpButtonVariant.primary && isEnabled
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  )
                : null,
            child: _buildButton(child),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Widget content) {
    return switch (widget.variant) {
      MpButtonVariant.primary => ElevatedButton(
          onPressed: null, // Handled by GestureDetector
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: widget.onPressed == null ? AppColors.border : AppColors.primary,
            disabledForegroundColor: Colors.white,
          ),
          child: content,
        ),
      MpButtonVariant.secondary => OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: AppColors.primary,
          ),
          child: content,
        ),
      MpButtonVariant.ghost => TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            disabledForegroundColor: AppColors.primary,
          ),
          child: content,
        ),
      MpButtonVariant.danger => ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: widget.onPressed == null ? AppColors.border : AppColors.error,
            disabledForegroundColor: Colors.white,
          ),
          child: content,
        ),
    };
  }
}
