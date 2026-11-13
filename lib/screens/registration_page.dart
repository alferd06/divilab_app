import 'package:flutter/material.dart';
import '../data/user_repository.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _form1 = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  final _birth = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _code = TextEditingController();

  int _step = 1;
  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _saving = false;
  String? _gender;
  bool _genderError = false;
  String? _emailError;

  @override
  void dispose() {
    for (final c in [_email, _password, _confirm, _name, _birth, _height, _weight, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  String? _positiveNumber(String? v, String label) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (n == null || n <= 0) return '$label harus berupa angka lebih dari 0';
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _birth.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _next() async {
    _emailError = null;
    if (!_form1.currentState!.validate()) return;
    final taken = await UserRepository.emailExists(_email.text);
    if (!mounted) return;
    if (taken) {
      setState(() => _emailError = 'Email sudah terdaftar');
      _form1.currentState!.validate();
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _submit() async {
    final formOk = _form2.currentState!.validate();
    setState(() => _genderError = _gender == null);
    if (!formOk || _gender == null) return;
    setState(() => _saving = true);
    try {
      await UserRepository.register(
        email: _email.text,
        password: _password.text,
        fullName: _name.text,
        gender: _gender!,
        birthDate: _birth.text,
        heightCm: double.parse(_height.text.replaceAll(',', '.')),
        weightKg: double.parse(_weight.text.replaceAll(',', '.')),
        productCode: _code.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil, silakan login')));
      Navigator.pop(context); // kembali ke Login
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
    }
  }

  void _back() {
    if (_step == 2) {
      setState(() => _step = 1);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _step1() => Form(
    key: _form1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email & Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (_) => _emailError = null,
          validator: (v) {
            final value = (v ?? '').trim();
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return _emailError;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          obscureText: _hidePass,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _hidePass = !_hidePass),
            ),
          ),
          validator: (v) =>
          (v ?? '').length < 6 ? 'Password minimal 6 karakter' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirm,
          obscureText: _hideConfirm,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            suffixIcon: IconButton(
              icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
            ),
          ),
          validator: (v) =>
          v != _password.text ? 'Konfirmasi password tidak sama' : null,
        ),
      ],
    ),
  );

  Widget _step2() => Form(
    key: _form2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Personal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nama Lengkap'),
          validator: (v) => _required(v, 'Nama lengkap'),
        ),
        const SizedBox(height: 12),
        const Text('Jenis Kelamin'),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          emptySelectionAllowed: true,
          segments: const [
            ButtonSegment(value: 'Laki-Laki', label: Text('Laki-Laki')),
            ButtonSegment(value: 'Perempuan', label: Text('Perempuan')),
          ],
          selected: _gender == null ? <String>{} : {_gender!},
          onSelectionChanged: (s) => setState(() {
            _gender = s.isEmpty ? null : s.first;
            _genderError = false;
          }),
        ),
        if (_genderError)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Jenis kelamin wajib dipilih',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _birth,
          readOnly: true,
          onTap: _pickDate,
          decoration: const InputDecoration(
              labelText: 'Tanggal Lahir',
              suffixIcon: Icon(Icons.calendar_today)),
          validator: (v) => _required(v, 'Tanggal lahir'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tinggi (cm)'),
                validator: (v) => _positiveNumber(v, 'Tinggi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weight,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Berat (kg)'),
                validator: (v) => _positiveNumber(v, 'Berat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _code,
          decoration: const InputDecoration(
              labelText: 'Kode Produksi',
              suffixIcon: Icon(Icons.camera_alt_outlined)), // tampilan saja
          validator: (v) => _required(v, 'Kode produksi'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
        title: const Text('Registrasi'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: _step / 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _step == 1 ? _step1() : _step2(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : (_step == 1 ? _next : _submit),
                  child: Text(_saving ? 'Menyimpan...' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}