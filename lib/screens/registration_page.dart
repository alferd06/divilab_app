import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_field.dart';

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

  bool _passwordValid(String v) =>
      v.length >= 10 &&
          RegExp(r'[A-Z]').hasMatch(v) &&
          RegExp(r'[a-z]').hasMatch(v) &&
          RegExp(r'[^A-Za-z0-9]').hasMatch(v);

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
      Navigator.pop(context);
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

  Widget _genderBox(String value) {
    final selected = _gender == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() {
          _gender = value;
          _genderError = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step1() => Form(
    key: _form1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buat Akun',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Daftar untuk memulai'),
        const SizedBox(height: 32),
        LabeledField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => _emailError = null,
          validator: (v) {
            final value = (v ?? '').trim();
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return _emailError;
          },
        ),
        const SizedBox(height: 20),
        LabeledField(
          label: 'Password',
          controller: _password,
          obscure: _hidePass,
          onToggleObscure: () => setState(() => _hidePass = !_hidePass),
          validator: (v) => _passwordValid(v ?? '')
              ? null
              : 'Password belum memenuhi aturan',
          helper: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '1 huruf besar — 1 huruf kecil — 1 simbol — minimal 10 karakter',
                  style:
                  TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LabeledField(
          label: 'Konfirmasi password',
          controller: _confirm,
          obscure: _hideConfirm,
          onToggleObscure: () =>
              setState(() => _hideConfirm = !_hideConfirm),
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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        LabeledField(
          label: 'Nama Lengkap',
          controller: _name,
          validator: (v) => _required(v, 'Nama lengkap'),
        ),
        const SizedBox(height: 20),
        const Text('Jenis Kelamin', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            _genderBox('Laki-Laki'),
            const SizedBox(width: 12),
            _genderBox('Perempuan'),
          ],
        ),
        if (_genderError)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Jenis kelamin wajib dipilih',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 20),
        LabeledField(
          label: 'Tanggal Lahir',
          controller: _birth,
          readOnly: true,
          onTap: _pickDate,
          suffix: const Icon(Icons.calendar_today_outlined),
          validator: (v) => _required(v, 'Tanggal lahir'),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledField(
                label: 'Tinggi (cm)',
                controller: _height,
                keyboardType: TextInputType.number,
                validator: (v) => _positiveNumber(v, 'Tinggi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: 'Berat (kg)',
                controller: _weight,
                keyboardType: TextInputType.number,
                validator: (v) => _positiveNumber(v, 'Berat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LabeledField(
          label: 'Kode Produksi',
          controller: _code,
          suffix: const Icon(Icons.camera_alt_outlined), // tampilan saja
          validator: (v) => _required(v, 'Kode produksi'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _step / 2,
                  minHeight: 6,
                  backgroundColor: AppColors.disabled,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: _back,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _step == 1 ? _step1() : _step2(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _saving ? null : (_step == 1 ? _next : _submit),
                child: Text(_saving ? 'Menyimpan...' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}