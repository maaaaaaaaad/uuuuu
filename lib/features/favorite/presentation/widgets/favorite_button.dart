import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/favorite/presentation/providers/favorites_provider.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String shopId;
  final double size;

  const FavoriteButton({
    super.key,
    required this.shopId,
    this.size = 40,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(bool currentStatus) async {
    if (_isToggling) return;

    setState(() => _isToggling = true);
    _controller.forward().then((_) => _controller.reverse());

    final notifier = ref.read(favoritesNotifierProvider.notifier);
    if (currentStatus) {
      await notifier.removeFavorite(widget.shopId);
    } else {
      await notifier.addFavorite(widget.shopId);
    }

    ref.invalidate(favoriteStatusProvider(widget.shopId));
    setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteStatusAsync = ref.watch(favoriteStatusProvider(widget.shopId));

    return favoriteStatusAsync.when(
      loading: () => _buildButton(
        icon: Icons.favorite_border,
        isFavorite: false,
        isLoading: true,
      ),
      error: (error, stackTrace) => _buildButton(
        icon: Icons.favorite_border,
        isFavorite: false,
        isLoading: false,
      ),
      data: (isFavorite) => _buildButton(
        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
        isFavorite: isFavorite,
        isLoading: false,
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isFavorite,
    required bool isLoading,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: isLoading || _isToggling
              ? null
              : () => _toggleFavorite(isFavorite),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: SemanticColors.background.appBar,
                borderRadius: BorderRadius.circular(widget.size / 2),
                border: Border.all(color: SemanticColors.border.glass),
              ),
              child: Center(
                child: _isToggling
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SemanticColors.icon.accent,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 20,
                        color: isFavorite
                            ? SemanticColors.state.error
                            : SemanticColors.icon.primary,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
