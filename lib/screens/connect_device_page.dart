import 'package:flutter/material.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'measurement_page.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key});
  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  bool _connecting = false;

  Future<void> _connect() async {
    setState(() => _connecting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulasi Bluetooth
    if (!mounted) return;
    setState(() => _connecting = false);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MeasurementPage()),
    );
    // Setelah halaman Pengukuran ditutup, ikut tutup halaman ini supaya
    // Dashboard yang menunggu (HomeShell) langsung memuat ulang data.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final code = Session.user!['product_code'] as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hubungkan Perangkat Sekarang',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  'Pastikan Bluetooth Anda dalam keadaan aktif atau hidup '
                      'sebelum menghubungkan ke perangkat DiViLab Optima berikut.',
                  style: TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 220,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.monitor_heart_outlined,
                      size: 72, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('DiViLab Optima',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('Kode : $code',
                    style: const TextStyle(color: Colors.black54)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: Color(0xFFE08A00)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Menghubungkan ke perangkat lain akan memutuskan '
                              'koneksi perangkat yang sedang aktif.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _connecting ? null : _connect,
                child: Text(
                    _connecting ? 'Menghubungkan...' : 'Hubungkan Bluetooth'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}