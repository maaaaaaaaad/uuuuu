import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static final BoxShadow shadowSoft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 10.0,
    offset: Offset.zero,
  );

  static final BoxShadow shadowMedium = BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 20.0,
    offset: Offset.zero,
  );

  static final BoxShadow shadowFloat = BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 30.0,
    offset: const Offset(0, 10),
  );

  static final List<BoxShadow> elevated3D = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> card3D = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.8),
      blurRadius: 1,
      offset: const Offset(-1, -1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(1, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(2, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(4, 8),
    ),
  ];

  static final List<BoxShadow> cardPopOut = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.9),
      blurRadius: 0,
      spreadRadius: 1,
      offset: const Offset(-0.5, -0.5),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 3,
      offset: const Offset(1, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(3, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(5, 10),
    ),
  ];
}
