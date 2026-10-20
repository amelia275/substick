import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../services/auth_service.dart';
import 'auth_widgets.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String email;

  const LoginPasswordScreen({super.key, required this.email});

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get _canSubmit => _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: widget.email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Masukkan kata sandi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHelperText(widget.email),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hint: 'Kata sandi',
            isPassword: true,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (_errorMessage != null) AuthErrorText(_errorMessage!),
        ],
      ),
      bottom: AuthPrimaryButton(
        label: 'Masuk',
        enabled: _canSubmit,
        isLoading: _isLoading,
        onPressed: _submit,
      ),
    );
  }
}