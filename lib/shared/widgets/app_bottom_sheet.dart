import 'package:flutter/material.dart';

/// 시스템 UI(안드로이드 네비/제스처 바)와 키보드를 자동 회피하는 BottomSheet wrapper.
///
/// `showModalBottomSheet`를 직접 호출하지 말고 항상 이 함수를 사용한다.
/// Architecture Test가 `lib/` 안에서 raw `showModalBottomSheet(` 호출을 거부한다.
///
/// 자동 처리:
/// - `SafeArea(top: false)` — 하단 시스템 인셋 (제스처 바, 네비 바, 노치)
/// - `viewInsets.bottom` — 키보드 높이
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: shape,
    builder: (innerContext) => DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(innerContext).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(innerContext).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: builder(innerContext),
        ),
      ),
    ),
  );
}

/// 시스템 UI를 자동 회피하는 Dialog wrapper.
///
/// `showDialog`를 직접 호출하지 말고 항상 이 함수를 사용한다.
/// Architecture Test가 `lib/` 안에서 raw `showDialog(` 호출을 거부한다.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: (innerContext) => SafeArea(
      child: builder(innerContext),
    ),
  );
}
