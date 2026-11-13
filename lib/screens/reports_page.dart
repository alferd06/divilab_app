import 'package:flutter/material.dart';
import '../data/measurement_repository.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'history_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, dynamic>? _glucose;
  Map<String, dynamic>? _bp;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Session.user!['id'] as int;
    final g = await MeasurementRepository.latest(userId, MeasurementRepository.glucose);
    final bp = await MeasurementRepository.latest(userId, MeasurementRepository.tekananDarah);

    if (!mounted) return;
    setState(() {
      _glucose = g;
      _bp = bp;
    });
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final d = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final pad = (int n) => n.toString().padLeft(2, '0');
    final timeStr = '${pad(d.hour)}:${pad(d.minute)}';

    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '$timeStr, Hari ini';
    }
    return '${pad(d.day)}/${pad(d.month)}/${d.year}';
  }

  (Color, Color) _getStyle(String? status) {
    switch (status) {
      case 'Normal': return (const Color(0xFFD8F3E1), const Color(0xFF2E9E5B));
      case 'Tinggi': return (const Color(0xFFFFE0D6), const Color(0xFFE05A2B));
      case 'Rendah': return (const Color(0xFFD6ECFA), const Color(0xFF1E88E5));
      default: return (const Color(0xFFEFEFEF), const Color(0xFF9E9E9E));
    }
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required String type,
    Map<String, dynamic>? data,
  }) {
    final hasData = data != null;
    final status = hasData ? data['status'] as String : null;
    final timeStr = hasData ? _formatTime(data['created_at'] as String) : '';
    final style = _getStyle(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (type == MeasurementRepository.glucose ||
            type == MeasurementRepository.tekananDarah)
            ? () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoryPage(type: type)),
            );
            if (mounted) _loadData(); // muat ulang setelah kembali dari riwayat
            }
            : null,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              if (hasData) const SizedBox(height: 4),
                              if (hasData) Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: style.$1, borderRadius: BorderRadius.circular(12)),
                          child: Text(status ?? 'Belum ada data', style: TextStyle(color: style.$2, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 6, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = Session.user!['full_name'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              Text(name, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Pengukuran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCard(
                title: 'Gula Darah',
                icon: Icons.water_drop,
                color: Colors.red,
                type: MeasurementRepository.glucose,
                data: _glucose,
              ),
              _buildCard(
                title: 'Kolesterol',
                icon: Icons.favorite,
                color: Colors.pink,
                type: 'kolesterol',
              ),
              _buildCard(
                title: 'Asam Urat',
                icon: Icons.science,
                color: Colors.green,
                type: 'asam_urat',
              ),
              _buildCard(
                title: 'Tekanan Darah',
                icon: Icons.monitor_heart,
                color: Colors.deepPurple,
                type: MeasurementRepository.tekananDarah,
                data: _bp,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}