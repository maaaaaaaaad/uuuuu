import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_colors.dart';

class SemanticColors {
  SemanticColors._();

  static final background = _BackgroundColors();

  static final button = _ButtonColors();

  static final text = _TextColors();

  static final icon = _IconColors();

  static final border = _BorderColors();

  static final indicator = _IndicatorColors();

  static final state = _StateColors();

  static final overlay = _OverlayColors();

  static final special = _SpecialColors();
}

class _BackgroundColors {
  final Color page = Colors.transparent;

  final Color card = AppColors.glassWhite;

  Color get cardAccent => AppColors.glassWhite;

  Color get cardPink => AppColors.pastelPink.withValues(alpha: 0.3);

  final Color input = Colors.white;

  Color get inputDisabled => Colors.grey.shade100;

  Color get inputTranslucent => Colors.white.withValues(alpha: 0.5);

  final Color navigation = AppColors.glassWhite;

  final Color appBar = AppColors.glassWhite;

  final Color bottomSheet = AppColors.glassWhite;

  Color get chip => Colors.grey[100]!;

  final Color chipSelected = AppColors.pastelPink;

  Color get placeholder => Colors.grey[200]!;

  Color get review => Colors.grey[100]!;

  Color get imagePlaceholder => Colors.grey[200]!;

  Color get avatar => Colors.grey[300]!;
}

class _ButtonColors {
  final Color primary = AppColors.pastelPink;

  final Color primaryText = Colors.white;

  final Color secondary = AppColors.mint;

  final Color secondaryText = Colors.white;

  Color get disabled => Colors.grey[200]!;

  Color get disabledText => Colors.grey[400]!;

  final Color textButton = AppColors.mint;

  final Color textButtonPink = AppColors.pastelPink;

  Color get outlineBorder => Colors.grey[400]!;

  Color get outlineText => Colors.grey[600]!;

  Color get kakao => AppColors.kakaoYellow.withValues(alpha: 0.9);

  Color get kakaoBorder => Colors.white.withValues(alpha: 0.3);

  final Color kakaoText = Colors.black87;
}

class _TextColors {
  final Color primary = AppColors.textPrimary;

  Color get secondary => Colors.grey[600]!;

  Color get hint => Colors.grey[400]!;

  Color get disabled => Colors.grey[500]!;

  final Color link = AppColors.mint;

  final Color linkPink = AppColors.pastelPink;

  final Color onDark = Colors.white;

  Color get onDarkSecondary => Colors.white.withValues(alpha: 0.9);

  final Color accent = AppColors.accentPink;

  final Color price = AppColors.accentPink;

  final Color count = AppColors.darkPink;

  Color get highlight => Colors.pink[600]!;
}

class _IconColors {
  Color get primary => Colors.grey[700]!;

  Color get secondary => Colors.grey[600]!;

  Color get disabled => Colors.grey[400]!;

  final Color accent = AppColors.pastelPink;

  final Color accentPink = AppColors.pastelPink;

  final Color selected = AppColors.pastelPink;

  Color get unselected => Colors.grey[600]!;

  final Color onDark = Colors.white;

  final Color starFilled = Colors.amber;

  Color get starEmpty => Colors.grey[400]!;

  final Color starSelectable = AppColors.pastelPink;

  Color get starSelectableEmpty => Colors.grey[300]!;
}

class _BorderColors {
  final Color glass = AppColors.glassBorder;

  Color get primary => Colors.grey[200]!;

  Color get secondary => Colors.grey[300]!;

  final Color focus = AppColors.pastelPink;

  final Color focusMint = AppColors.mint;

  Color get divider => Colors.grey[200]!;

  Color get input => Colors.grey[200]!;

  Color get inputDisabled => Colors.grey.shade300;
}

class _IndicatorColors {
  final Color loading = AppColors.mint;

  final Color loadingPink = AppColors.pastelPink;

  final Color loadingOnDark = Colors.white;

  final Color pageActive = AppColors.pastelPink;

  final Color pageInactive = AppColors.lightPink;

  Color get carouselActive => Colors.pink[200]!;

  Color get carouselInactive => Colors.grey[300]!;

  final Color selection = AppColors.pastelPink;
}

class _StateColors {
  final Color success = Colors.green;

  final Color error = Colors.red;

  final Color warning = Colors.orange;

  final Color info = Colors.blue;

  final Color open = Colors.black87;

  final Color closed = Colors.red;
}

class _OverlayColors {
  Color get dialogBarrier => Colors.black.withValues(alpha: 0.3);

  Color get loadingBackground => Colors.white.withValues(alpha: 0.85);

  Color get imageGradient => Colors.black.withValues(alpha: 0.5);

  Color get shadowLight => Colors.black.withValues(alpha: 0.1);

  Color get shadowMedium => Colors.black.withValues(alpha: 0.15);

  Color get shadowStrong => Colors.black.withValues(alpha: 0.2);

  Color get avatarShadow => Colors.black.withValues(alpha: 0.2);

  Color get card3dShadow => Colors.grey.withValues(alpha: 0.15);

  Color get card3dHighlight => Colors.white.withValues(alpha: 0.8);

  Color get neumorphicDark => Colors.grey.withValues(alpha: 0.2);

  Color get neumorphicLight => Colors.white.withValues(alpha: 0.9);
}

class _SpecialColors {
  final Color tagNew = AppColors.pastelPink;

  final Color tagNewText = Colors.white;

  final Color tagDiscount = AppColors.accentPink;

  final Color tagDiscountText = Colors.white;

  final Color badge = AppColors.lightPink;

  final Color badgeText = AppColors.accentPink;

  Color get ratingBadge => AppColors.pastelPink.withValues(alpha: 0.15);

  Color get ratingBadgeBorder => AppColors.pastelPink.withValues(alpha: 0.5);

  Color get pinkHighlight => Colors.pink[50]!;

  Color get pinkHighlightText => Colors.pink[700]!;

  Color get todayHighlight => Colors.pink[600]!;

  final Color transparent = Colors.transparent;
}
