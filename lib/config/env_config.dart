import 'package:flutter/foundation.dart';

class EnvConfig {
  final String name;
  final String apiBaseUrl;
  final bool isDebug;

  const EnvConfig._({
    required this.name,
    required this.apiBaseUrl,
    required this.isDebug,
  });

  static const EnvConfig development = EnvConfig._(
    name: 'development',
    apiBaseUrl: 'http://localhost:8080',
    isDebug: true,
  );

  static const EnvConfig production = EnvConfig._(
    name: 'production',
    apiBaseUrl: 'https://api.jellomark.com',
    isDebug: false,
  );

  static EnvConfig get current => kDebugMode ? development : production;
}
