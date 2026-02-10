import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jellomark/core/notification/local_notification_service.dart';
import 'package:jellomark/features/reservation/presentation/pages/reservation_detail_page.dart';

class NotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final LocalNotificationService? _localNotificationService;

  NotificationHandler({
    required this.navigatorKey,
    LocalNotificationService? localNotificationService,
  }) : _localNotificationService = localNotificationService;

  static const _detailNavigationTypes = {
    'RESERVATION_CONFIRMED',
    'RESERVATION_REJECTED',
    'RESERVATION_COMPLETED',
    'RESERVATION_NO_SHOW',
  };

  static const _reminderCancelTypes = {
    'RESERVATION_REJECTED',
    'RESERVATION_CANCELLED',
    'RESERVATION_NO_SHOW',
  };

  static const _reminderDuration = Duration(hours: 3);

  void handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final payload = buildPayload(message.data);
    _localNotificationService?.show(
      id: message.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: payload,
    );

    _handleReminderForMessage(message.data);
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final reservationId = data['reservationId'] as String?;

    if (shouldNavigateToDetail(type) && reservationId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ReservationDetailPage(reservationId: reservationId),
        ),
      );
    }
  }

  void handleNotificationResponsePayload(String? payload) {
    final data = parsePayload(payload);
    if (data.isNotEmpty) {
      handleNotificationTap(data);
    }
  }

  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      handleNotificationTap(message.data);
    }
  }

  static bool shouldNavigateToDetail(String? type) {
    return type != null && _detailNavigationTypes.contains(type);
  }

  static String buildPayload(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> parsePayload(String? payload) {
    if (payload == null) return {};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  static DateTime computeReminderTime(DateTime reservationTime) {
    return reservationTime.subtract(_reminderDuration);
  }

  static bool shouldScheduleReminder(DateTime reminderTime) {
    return reminderTime.isAfter(DateTime.now());
  }

  static DateTime? parseReservationDateTime(String? date, String? time) {
    if (date == null || time == null) return null;
    try {
      final dateParts = date.split('-');
      if (dateParts.length != 3) return null;
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final timeParts = time.split(':');
      if (timeParts.length < 2) return null;
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static int reminderNotificationId(String reservationId) {
    return reservationId.hashCode;
  }

  static bool shouldCancelReminder(String? type) {
    return type != null && _reminderCancelTypes.contains(type);
  }

  void _handleReminderForMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final reservationId = data['reservationId'] as String?;
    if (reservationId == null) return;

    if (type == 'RESERVATION_CONFIRMED') {
      _scheduleReservationReminder(data);
    } else if (shouldCancelReminder(type)) {
      _cancelReservationReminder(reservationId);
    }
  }

  void _scheduleReservationReminder(Map<String, dynamic> data) {
    final reservationId = data['reservationId'] as String?;
    final dateStr = data['reservationDate'] as String?;
    final timeStr = data['startTime'] as String?;
    final shopName = data['shopName'] as String? ?? '매장';
    final treatmentName = data['treatmentName'] as String? ?? '시술';
    if (reservationId == null) return;

    final reservationTime = parseReservationDateTime(dateStr, timeStr);
    if (reservationTime == null) return;

    final reminderTime = computeReminderTime(reservationTime);
    if (!shouldScheduleReminder(reminderTime)) return;

    _localNotificationService?.scheduleReminder(
      id: reminderNotificationId(reservationId),
      title: '예약 3시간 전입니다',
      body: '$shopName - $treatmentName $timeStr',
      scheduledTime: reminderTime,
      payload: buildPayload(data),
    );
  }

  void _cancelReservationReminder(String reservationId) {
    _localNotificationService?.cancel(reminderNotificationId(reservationId));
  }
}
