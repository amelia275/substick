import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const Color _titleColor = Color(0xFF1A1A1A);
const Color _hintColor = Color(0xFF9A9A9A);
const Color _fieldBorder = Color(0xFFD0D0D0);
const Color _fieldBorderFocused = Color(0xFF6E6E6E);
const Color _buttonBorder = Color(0xFFE0E0E0);
const Color _disabledButton = Color(0xFFEEEEEE);
const Color _disabledText = Color(0xFFB3B3B3);

bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.stacked_bar_chart,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}

/// Kerangka layar: tombol back, judul serif besar, isi, lalu tombol di bawah.
class AuthPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget bottom;
  final bool pinBottom;

  const AuthPage({
    super.key,
    required this.title,
    required this.body,
    required this.bottom,
    this.pinBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 26,
                    color: _titleColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    body,
                    if (!pinBottom) ...[
                      const SizedBox(height: 28),
                      bottom,
                    ],
                  ],
                ),
              ),
            ),
            if (pinBottom)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autocorrect: false,
      enableSuggestions: !widget.isPassword,
      cursorColor: _titleColor,
      style: const TextStyle(fontSize: 17, color: _titleColor),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(fontSize: 17, color: _hintColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(_fieldBorder, 1),
        enabledBorder: _border(_fieldBorder, 1),
        focusedBorder: _border(_fieldBorderFocused, 2),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.iconSecondary,
                ),
              )
            : null,
      ),
    );
  }
}

/// Tombol utama. Abu-abu saat belum bisa dipakai, oranye saat aktif.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final double height;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isLoading ? AppColors.primary : _disabledButton,
          disabledForegroundColor: isLoading ? Colors.white : _disabledText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class AuthOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? leading;
  final double height;

  const AuthOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _titleColor,
          side: const BorderSide(color: _buttonBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthHelperText extends StatelessWidget {
  final String text;

  const AuthHelperText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class AuthErrorText extends StatelessWidget {
  final String message;

  const AuthErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: AppColors.error),
      ),
    );
  }
}