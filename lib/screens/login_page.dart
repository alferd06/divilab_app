import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/divilab_logo.dart';
import '../widgets/labeled_field.dart';
import '../widgets/language_chip.dart';
import 'home_shell.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;
  String? _error;

  bool get _canSubmit =>
      _email.text.trim().isNotEmpty && _password.text.isNotEmpty && !_loading;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final user = await UserRepository.login(_email.text, _password.text);
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Email atau password salah';
      });
      return;
    }
    Session.user = user;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                  alignment: Alignment.centerLeft, child: LanguageChip()),
              const SizedBox(height: 48),
              const Center(child: DiviLabLogo()),
              const SizedBox(height: 48),
              const Text('Login atau Daftar',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              LabeledField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'Password',
                controller: _password,
                obscure: _hidePass,
                onToggleObscure: () => setState(() => _hidePass = !_hidePass),
                onChanged: (_) => setState(() => _error = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              const Text('Lupa Password?',
                  style: TextStyle(color: AppColors.primary, fontSize: 16)),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Belum punya akun? ',
                      style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegistrationPage()),
                    ),
                    child: const Text('Registrasi',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _canSubmit ? _login : null,
                child: Text(_loading ? 'Memproses...' : 'Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}