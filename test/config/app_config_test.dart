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

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore'),
          (MethodCall methodCall) async {
            return <String, dynamic>{
              'name': '[DEFAULT]',
              'options': <String, dynamic>{
                'apiKey': 'test',
                'appId': 'test',
                'messagingSenderId': 'test',
                'projectId': 'test',
              },
              'pluginConstants': <String, dynamic>{},
            };
          },
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeApp'),
          (MethodCall methodCall) async {
            return <String, dynamic>{
              'name': '[DEFAULT]',
              'options': <String, dynamic>{
                'apiKey': 'test',
                'appId': 'test',
                'messagingSenderId': 'test',
                'projectId': 'test',
              },
              'pluginConstants': <String, dynamic>{},
            };
          },
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_messaging'),
          (MethodCall methodCall) async => null,
        );

        try {
          await AppConfig.initializeApp();
        } catch (e) {
          // Firebase may still fail, but we can check orientation was called
        }

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
