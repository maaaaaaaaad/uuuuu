import 'package:flutter/material.dart';
import 'package:jellomark/app.dart';
import 'package:jellomark/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initializeApp();
  runApp(const JelloMarkApp());
}
