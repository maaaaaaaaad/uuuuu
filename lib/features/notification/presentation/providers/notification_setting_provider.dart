import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/notification/data/datasources/notification_setting_local_datasource.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum NotificationToggleResult { success, denied, deniedForever, error }

class NotificationSettingState {
  final bool isEnabled;
  final AuthorizationStatus permissionStatus;

  const NotificationSettingState({
    required this.isEnabled,
    required this.permissionStatus,
  });

  NotificationSettingState copyWith({
    bool? isEnabled,
    AuthorizationStatus? permissionStatus,
  }) {
    return NotificationSettingState(
      isEnabled: isEnabled ?? this.isEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
    );
  }
}

bool _isAuthorized(AuthorizationStatus status) {
  return status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}

final notificationSettingLocalDataSourceProvider =
    Provider<NotificationSettingLocalDataSource>(
      (ref) => NotificationSettingLocalDataSourceImpl(),
    );

final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

class NotificationSettingNotifier
    extends AsyncNotifier<NotificationSettingState> {
  @override
  Future<NotificationSettingState> build() async {
    final dataSource = ref.watch(notificationSettingLocalDataSourceProvider);
    final messaging = ref.watch(firebaseMessagingProvider);

    final userIntent = await dataSource.isNotificationEnabled();
    final settings = await messaging.getNotificationSettings();
    final permissionStatus = settings.authorizationStatus;

    return NotificationSettingState(
      isEnabled: userIntent && _isAuthorized(permissionStatus),
      permissionStatus: permissionStatus,
    );
  }

  Future<NotificationToggleResult> toggle() async {
    final currentState = state.requireValue;
    final dataSource = ref.read(notificationSettingLocalDataSourceProvider);
    final messaging = ref.read(firebaseMessagingProvider);

    if (currentState.isEnabled) {
      await dataSource.setNotificationEnabled(false);
      state = AsyncData(currentState.copyWith(isEnabled: false));
      return NotificationToggleResult.success;
    }

    final current = await messaging.getNotificationSettings();
    var status = current.authorizationStatus;

    if (status == AuthorizationStatus.notDetermined) {
      final requested = await messaging.requestPermission();
      status = requested.authorizationStatus;
    }

    if (!_isAuthorized(status)) {
      return status == AuthorizationStatus.denied
          ? NotificationToggleResult.deniedForever
          : NotificationToggleResult.denied;
    }

    await dataSource.setNotificationEnabled(true);
    state = AsyncData(
      currentState.copyWith(isEnabled: true, permissionStatus: status),
    );
    return NotificationToggleResult.success;
  }

  Future<void> goToAppSettings() async {
    await ph.openAppSettings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final notificationSettingNotifierProvider =
    AsyncNotifierProvider<
      NotificationSettingNotifier,
      NotificationSettingState
    >(NotificationSettingNotifier.new);
