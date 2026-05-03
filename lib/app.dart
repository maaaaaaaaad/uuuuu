import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jellomark/config/theme.dart';
import 'package:jellomark/core/notification/navigator_key.dart';
import 'package:jellomark/features/auth/presentation/pages/login_page.dart';
import 'package:jellomark/features/auth/presentation/pages/splash_page.dart';
import 'package:jellomark/features/home/presentation/pages/home_page.dart';

class JelloMarkApp extends StatelessWidget {
  const JelloMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '젤로마크',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
