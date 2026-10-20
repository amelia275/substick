import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../services/auth_service.dart';
import 'auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isFormValid {
    final username = _usernameController.text.trim();
    return _nameController.text.trim().isNotEmpty &&
        username.length >= 3 &&
        RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(username) &&
        isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 8;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isFormValid || _isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
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
      title: 'Buat akunmu',
      pinBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _nameController,
            hint: 'Nama',
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _usernameController,
            hint: 'Username',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _emailController,
            hint: 'Alamat email',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            hint: 'Kata sandi',
            isPassword: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 10),
          const AuthHelperText(
            'Username: huruf, angka, strip, atau garis bawah (minimal 3). '
            'Kata sandi minimal 8 karakter.',
          ),
          if (_errorMessage != null) AuthErrorText(_errorMessage!),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthPrimaryButton(
            label: 'Daftar',
            enabled: _isFormValid,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          AuthOutlinedButton(
            label: 'Sudah punya akun? Masuk',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}