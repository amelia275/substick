import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/token_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'auth_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    var route = '/welcome';
    final token = await TokenStorage.read();

    if (token != null) {
      try {
        await AuthService().fetchMe();
        route = '/home';
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          await TokenStorage.clear();
        } else {
          route = '/home';
        }
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: AuthLogo()),
    );
  }
}