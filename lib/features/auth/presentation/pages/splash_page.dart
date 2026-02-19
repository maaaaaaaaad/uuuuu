import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/auth/presentation/providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _warmupController = TextEditingController();
  final _warmupFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmupKeyboard();
      _checkAuthStatus();
    });
  }

  void _warmupKeyboard() {
    _warmupFocusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _warmupFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _warmupController.dispose();
    _warmupFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final checkAuthStatus = ref.read(checkAuthStatusUseCaseProvider);
      final result = await checkAuthStatus()
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      result.fold(
        (_) => Navigator.of(context).pushReplacementNamed('/login'),
        (_) => Navigator.of(context).pushReplacementNamed('/home'),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/splash/splash-jellomark01.png',
              width: 200,
              height: 200,
            ),
          ),
          Offstage(
            offstage: true,
            child: TextField(
              key: const Key('keyboard_warmup_textfield'),
              controller: _warmupController,
              focusNode: _warmupFocusNode,
            ),
          ),
        ],
      ),
    );
  }
}
