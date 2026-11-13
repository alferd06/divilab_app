import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/measurement_repository.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/strip_countdown_dialog.dart';

enum _Phase { waiting, running, done }

class MeasurementPage extends StatefulWidget {
  const MeasurementPage({super.key});
  @override
  State<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  static const _tickMs = 100;
  static const _waitTicks = 30; // 3 detik menunggu pembacaan alat
  static const _runTicks = 30; // 3 detik pengukuran berjalan

  final _rng = Random();
  Timer? _timer;
  int _ticks = 0;
  _Phase _phase = _Phase.waiting;
  int _liveValue = 0;
  double? _finalValue;
  String? _finalStatus;
  int _tab = 1; // 0 = Tekanan Darah, 1 = Pengukuran Darah

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel(); // wajib, supaya tidak ada setState setelah dispose
    super.dispose();
  }

  void _onTick(Timer t) {
    _ticks++;
    if (_ticks < _waitTicks) return;
    if (_ticks < _waitTicks + _runTicks) {
      setState(() {
        _phase = _Phase.running;
        _liveValue = 60 + _rng.nextInt(141);
      });
      return;
    }
    t.cancel();
    _finish();
  }

  Future<void> _finish() async {
    final value = (60 + _rng.nextInt(141)).toDouble(); // 60-200 mg/dL
    final status = MeasurementRepository.glucoseStatus(value);
    try {
      await MeasurementRepository.insert(
        userId: Session.user!['id'] as int,
        type: MeasurementRepository.glucose,
        value: value,
        unit: 'mg/dL',
        status: status,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan hasil: $e')));
      return;
    }
    if (!mounted) return;
    setState(() {
      _phase = _Phase.done;
      _finalValue = value;
      _finalStatus = status;
    });
    if (!mounted) return;
    setState(() {
      _phase = _Phase.done;
      _finalValue = value;
      _finalStatus = status;
    });
    await showStripCountdownDialog(context); // <- baris baru
  }

  void _soon(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget _tabBar() {
    Widget seg(int i, String label) {
      final selected = _tab == i;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _tab = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        seg(0, 'Tekanan Darah'),
        seg(1, 'Pengukuran Darah'),
      ]),
    );
  }

  Widget _statusCard() {
    final running = _phase == _Phase.running;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E6EC)),
      ),
      child: Column(
        children: [
          Text(
            running ? 'Pengukuran sedang berjalan' : 'Menunggu pembacaan alat',
            style: const TextStyle(color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Gula Darah', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            running ? '$_liveValue' : '-',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: running ? AppColors.primary : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloodSugarTab(String name) {
    final done = _phase == _Phase.done;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusCard(),
        const SizedBox(height: 24),
        const Text('Hasil Akhir Pengukuran:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ResultCard(
                title: 'Gula Darah',
                color: Colors.blue,
                value: done ? _finalValue!.toStringAsFixed(0) : '--',
                unit: 'mg/dl',
                status: done ? _finalStatus : null,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _ResultCard(
                  title: 'Kolesterol',
                  color: Colors.orange,
                  value: '--',
                  unit: 'mg/dl'),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _ResultCard(
                  title: 'Asam Urat',
                  color: Colors.green,
                  value: '--',
                  unit: 'mg/dl'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Sisa Strip Anda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: _StripCard(count: 10, label: 'Gula darah')),
            SizedBox(width: 8),
            Expanded(child: _StripCard(count: 2, label: 'Kolesterol')),
            SizedBox(width: 8),
            Expanded(child: _StripCard(count: 6, label: 'Asam urat')),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _soon('Fitur pembelian belum tersedia'),
          icon: const Icon(Icons.shopping_cart_outlined, size: 18),
          label: const Text('Beli strip'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = Session.user!['full_name'] as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengukuran',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pasien',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(name, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9E5B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Terhubung',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _tabBar(),
              const SizedBox(height: 16),
              if (_tab == 1)
                _bloodSugarTab(name)
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: Text('Segera hadir')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.color,
    required this.value,
    required this.unit,
    this.status,
  });

  final String title;
  final Color color;
  final String value;
  final String unit;
  final String? status;

  Color get _chipBg {
    switch (status) {
      case 'Normal':
        return const Color(0xFFD8F3E1);
      case 'Tinggi':
        return const Color(0xFFFFE0D6);
      case 'Rendah':
        return const Color(0xFFD6ECFA);
      default:
        return const Color(0xFFEFEFEF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(unit,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status ?? 'Detail',
                style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _StripCard extends StatelessWidget {
  const _StripCard({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          const SizedBox(height: 6),
          Text('$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}