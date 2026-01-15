import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool transparent;

  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.transparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: transparent ? _buildContent(context) : _buildGlassContent(context),
    );
  }

  Widget _buildGlassContent(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: SemanticColors.background.appBar,
            border: Border(
              bottom: BorderSide(
                color: SemanticColors.border.glass,
                width: 1,
              ),
            ),
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildLeading(context),
            Expanded(child: _buildTitle()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading!;
    }
    if (showBackButton) {
      return GlassIconButton(
        icon: Icons.arrow_back_ios_new,
        onTap: () => Navigator.maybePop(context),
      );
    }
    return const SizedBox(width: 40);
  }

  Widget _buildTitle() {
    if (title == null) return const SizedBox.shrink();
    return Center(
      child: Text(
        title!,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox(width: 40);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!
          .map((action) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: action,
              ))
          .toList(),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SemanticColors.background.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: SemanticColors.border.glass,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: SemanticColors.icon.primary,
        ),
      ),
    );
  }
}
