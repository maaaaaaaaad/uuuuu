import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_dimensions.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/app_shadows.dart';

enum GradientType { mint, pink, lavender }

class GradientCard extends StatefulWidget {
  final Widget child;
  final GradientType gradientType;
  final Gradient? customGradient;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.gradientType = GradientType.mint,
    this.customGradient,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {
  bool _isPressed = false;

  Gradient get _gradient {
    if (widget.customGradient != null) {
      return widget.customGradient!;
    }
    switch (widget.gradientType) {
      case GradientType.mint:
        return AppGradients.mintGradient;
      case GradientType.pink:
        return AppGradients.pinkGradient;
      case GradientType.lavender:
        return AppGradients.lavenderGradient;
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: AppShadows.elevated3D,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
