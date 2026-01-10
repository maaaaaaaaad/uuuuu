import 'package:flutter/material.dart';
import 'package:jellomark/config/theme.dart';

class JelloMarkApp extends StatelessWidget {
  const JelloMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '젤로마크',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const Scaffold(body: Center(child: Text('젤로마크'))),
    );
  }
}
