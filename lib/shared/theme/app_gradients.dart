import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient softWhiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.backgroundLight, AppColors.backgroundMedium],
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lavenderLight, AppColors.lavenderDark],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.teal, AppColors.mint],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.pastelPink, AppColors.softPink],
  );
}
