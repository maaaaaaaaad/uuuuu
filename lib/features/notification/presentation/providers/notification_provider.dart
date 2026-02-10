import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/core/di/injection_container.dart';
import 'package:jellomark/core/notification/fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return sl<FcmService>();
});

final notificationInitProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.read(fcmServiceProvider);
  await fcmService.initialize();
});
