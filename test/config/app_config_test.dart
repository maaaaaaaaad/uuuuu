import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('initializeApp', () {
      test('should lock screen orientation to portrait only', () async {
        TestWidgetsFlutterBinding.ensureInitialized();

        final List<MethodCall> calls = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (
              MethodCall methodCall,
            ) async {
              calls.add(methodCall);
              return null;
            });

        const naverMapChannel = MethodChannel('flutter_naver_map_sdk');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(naverMapChannel, (
              MethodCall methodCall,
            ) async {
              return null;
            });

        await AppConfig.initializeApp();

        final orientationCall = calls.firstWhere(
          (call) => call.method == 'SystemChrome.setPreferredOrientations',
          orElse: () => throw Exception('setPreferredOrientations not called'),
        );

        expect(orientationCall.arguments, [
          DeviceOrientation.portraitUp.toString(),
          DeviceOrientation.portraitDown.toString(),
        ]);
      });
    });
  });
}
