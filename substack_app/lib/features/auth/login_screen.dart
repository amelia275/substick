import 'package:flutter/material.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();

  bool get _canContinue => isValidEmail(_emailController.text);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_canContinue) return;
    Navigator.pushNamed(
      context,
      '/login/password',
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Apa email kamu?',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _emailController,
            hint: 'Alamat email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _continue(),
          ),
          const SizedBox(height: 10),
          const AuthHelperText('Masukkan email yang kamu pakai untuk mendaftar.'),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthPrimaryButton(
            label: 'Lanjutkan',
            enabled: _canContinue,
            onPressed: _continue,
          ),
          const SizedBox(height: 12),
          AuthOutlinedButton(
            label: 'Buat akun baru',
            onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
}