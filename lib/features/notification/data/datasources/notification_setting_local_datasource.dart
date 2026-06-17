import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationSettingLocalDataSource {
  Future<bool> isNotificationEnabled();
  Future<void> setNotificationEnabled(bool enabled);
}

class NotificationSettingLocalDataSourceImpl
    implements NotificationSettingLocalDataSource {
  static const String _notificationEnabledKey = 'notification_enabled';

  @override
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }
}
