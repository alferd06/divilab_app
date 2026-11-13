import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/language_chip.dart';
import '../widgets/onboarding_illustration.dart';
import 'login_page.dart';

class _Slide {
  const _Slide(this.title, this.body, this.asset, this.icon);
  final String title;
  final String body;
  final String asset;
  final IconData icon;
}

const _slides = <_Slide>[
  _Slide(
    'Lebih dari Sekadar Hasil',
    'Kesehatan bukan hanya tentang nilai saat ini, tetapi perjalanan menuju masa depan yang lebih baik.',
    'assets/images/onboarding_1.png',
    Icons.directions_walk,
  ),
  _Slide(
    'Pengingat & Konsistensi Sehat',
    'Mulai dari pengingat tepat waktu hingga sistem streak, bantu diri Anda tetap konsisten dalam pemeriksaan rutin.',
    'assets/images/onboarding_2.png',
    Icons.notifications_active_outlined,
  ),
  _Slide(
    'Koneksi Otomatis & Praktis',
    'Hubungkan perangkat dengan mudah. Terintegrasi otomatis melalui Bluetooth untuk pengalaman tanpa ribet.',
    'assets/images/onboarding_3.png',
    Icons.bluetooth_connected,
  ),
  _Slide(
    'Terhubung dengan Orang Terdekat',
    'Pantau kesehatan lebih tenang bersama keluarga atau pendamping. Hasil pengukuran dapat dipantau secara real-time dari mana saja.',
    'assets/images/onboarding_4.png',
    Icons.family_restroom,
  ),
  _Slide(
    'Prediksi Kesehatan dengan AI',
    'Teknologi AI membantu memprediksi kondisi kesehatan Anda di masa depan.',
    'assets/images/onboarding_5.png',
    Icons.auto_graph,
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _next() {
    if (_isLast) {
      _goLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _slide(_Slide s) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingIllustration(asset: s.asset, icon: s.icon),
            const SizedBox(height: 32),
            Text(s.title,
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(s.body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final active = i == _page;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.disabled,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const LanguageChip(),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _goLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.chipBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child:
                      const Text('Lewati', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _slide(_slides[i]),
              ),
            ),
            _dots(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _next,
                child: Text(_isLast ? 'Mulai' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}