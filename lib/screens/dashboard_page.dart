import 'package:flutter/material.dart';
import '../data/measurement_repository.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onMeasure});
  final VoidCallback onMeasure;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, Object?>? _glucose;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = Session.user!['id'] as int;
    final row =
    await MeasurementRepository.latest(userId, MeasurementRepository.glucose);
    if (!mounted) return;
    setState(() => _glucose = row);
  }

  Widget _header(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
              Row(
                children: [
                  const Text('Pemilik Akun',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9E5B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Online',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.alarm, color: Colors.white),
        const SizedBox(width: 16),
        const Icon(Icons.notifications_none, color: Colors.white),
      ],
    );
  }

  Widget _stat(Widget icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.user!;
    final name = user['full_name'] as String;
    final code = user['product_code'] as String;
    final g = _glucose;
    final glucoseValue =
    g == null ? '--' : (g['value'] as num).toStringAsFixed(0);
    final glucoseStatus = g == null ? null : g['status'] as String;

    return Container(
      color: const Color(0xFF1E8FE5),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: _header(name),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _stat(const Icon(Icons.monetization_on,
                        color: Color(0xFFFFB300), size: 18), '800', 'Poin'),
                    _stat(const Icon(Icons.confirmation_number,
                        color: AppColors.primary, size: 18), '1', 'Voucher'),
                    _stat(const SizedBox.shrink(), 'Blue', 'Member'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F6FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.monitor_heart_outlined,
                            size: 48, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text('DiVi Lab Optima',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('Kode : $code',
                          style: const TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle,
                            size: 10, color: Color(0xFF2E9E5B)),
                        const SizedBox(width: 6),
                        const Text('Alat sudah terhubung'),
                        const SizedBox(width: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 36), // wajib: tema default lebar tak terbatas
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: widget.onMeasure,
                          child: const Text('Ukur Sekarang'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text('Hasil pengukuran terakhir',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Gula Darah',
                            icon: Icons.water_drop,
                            color: Colors.red,
                            value: glucoseValue,
                            unit: 'mg/dL',
                            status: glucoseStatus,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _MetricCard(
                            title: 'Kolesterol',
                            icon: Icons.favorite,
                            color: Colors.pink,
                            value: '--',
                            unit: 'mg/dL',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Asam Urat',
                            icon: Icons.science,
                            color: Colors.green,
                            value: '--',
                            unit: 'mg/dL',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Tekanan Darah',
                            icon: Icons.monitor_heart,
                            color: Colors.deepPurple,
                            value: '--/--',
                            unit: 'mmHg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
    this.status,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String unit;
  final String? status;

  (Color, Color) _style() {
    switch (status) {
      case 'Normal':
        return (const Color(0xFFD8F3E1), const Color(0xFF2E9E5B));
      case 'Tinggi':
        return (const Color(0xFFFFE0D6), const Color(0xFFE05A2B));
      case 'Rendah':
        return (const Color(0xFFD6ECFA), const Color(0xFF1E88E5));
      default:
        return (const Color(0xFFEFEFEF), const Color(0xFF9E9E9E));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _style();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(unit, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status ?? 'Belum ada data',
                style: TextStyle(color: fg, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}