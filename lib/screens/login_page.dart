import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../services/session.dart';
import 'home_shell.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
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
    debugPrint('login: ${user['full_name']}'); // bukti AC, hapus setelah dicek
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('DiViLab',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A6E8))),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('Login',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                            _hidePass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hidePass = !_hidePass),
                      ),
                    ),
                    validator: (v) =>
                    (v ?? '').isEmpty ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  const Text('Lupa Password?',
                      style: TextStyle(color: Color(0xFF00A6E8))), // tampilan saja
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: Text(_loading ? 'Memproses...' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Belum punya akun? '),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegistrationPage()),
                        ),
                        child: const Text('Registrasi',
                            style: TextStyle(color: Color(0xFF00A6E8))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}