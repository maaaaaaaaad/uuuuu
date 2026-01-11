import 'package:flutter/material.dart';

class Card3D extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const Card3D({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.onTap,
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0;
  double _rotationY = 0;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _controller.addListener(_updateRotation);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateRotation);
    _controller.dispose();
    super.dispose();
  }

  void _updateRotation() {
    if (!mounted) return;
    if (_controller.isAnimating && _tapPosition == null) {
      setState(() {
        _rotationX = _rotationX * (1 - _controller.value);
        _rotationY = _rotationY * (1 - _controller.value);
      });
    }
  }

  void _onTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = details.localPosition;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    setState(() {
      _tapPosition = localPosition;
      _rotationY = (localPosition.dx - centerX) / centerX * 0.1;
      _rotationX = -(localPosition.dy - centerY) / centerY * 0.1;
    });
  }

  void _onTapUp(TapUpDetails details) {
    _tapPosition = null;
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _tapPosition = null;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotationX)
          ..rotateY(_rotationY),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                offset: const Offset(4, 4),
                blurRadius: 10,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              BoxShadow(
                offset: const Offset(-2, -2),
                blurRadius: 8,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
