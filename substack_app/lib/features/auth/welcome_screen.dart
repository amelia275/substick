import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'auth_widgets.dart';

class _Slide {
  final String highlight;
  final String rest;
  final String subtitle;

  const _Slide({
    required this.highlight,
    required this.rest,
    required this.subtitle,
  });
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const List<_Slide> _slides = [
    _Slide(
      highlight: 'Ide nyata,',
      rest: ' percakapan nyata',
      subtitle: 'Tempat orang mengatakan apa yang benar-benar mereka pikirkan',
    ),
    _Slide(
      highlight: 'Baca langsung,',
      rest: ' dari penulisnya',
      subtitle: 'Ikuti penulis dan publikasi favoritmu',
    ),
    _Slide(
      highlight: 'Menulis bebas,',
      rest: ' tanpa ribet',
      subtitle: 'Bagikan artikel dan catatan ke pembacamu',
    ),
  ];

  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showGoogleUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk dengan Google belum tersedia')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  AuthPrimaryButton(
                    label: 'Daftar gratis',
                    enabled: true,
                    height: 56,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                  const SizedBox(height: 12),
                  AuthOutlinedButton(
                    label: 'Lanjutkan dengan Google',
                    height: 46,
                    leading: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    onPressed: _showGoogleUnavailable,
                  ),
                  const SizedBox(height: 12),
                  AuthOutlinedButton(
                    label: 'Lanjutkan dengan email',
                    height: 46,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 18),
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
                        TextSpan(
                          text: 'Ketentuan Penggunaan',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: ' dan '),
                        TextSpan(
                          text: 'Kebijakan Privasi',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: ' ${AppConstants.appName}.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _WelcomeIllustration(),
            const SizedBox(height: 28),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: slide.highlight,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(text: slide.rest),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 38,
                height: 1.2,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder. Ganti dengan Image.asset('assets/images/...') kalau sudah punya gambar sendiri.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chat_bubble_outline_rounded,
            size: 84, color: Color(0xFF1A1A1A)),
        SizedBox(width: 18),
        Icon(Icons.chat_bubble_outline_rounded,
            size: 84, color: AppColors.primary),
      ],
    );
  }
}