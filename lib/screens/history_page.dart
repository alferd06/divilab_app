
import 'package:flutter/material.dart';
import '../data/measurement_repository.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  final String type;

  const HistoryPage({super.key, required this.type});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final userId = Session.user!['id'] as int;

    final rows = await MeasurementRepository.listByType(
      userId,
      widget.type,
      within: const Duration(days: 7),
    );

    if (!mounted) return;

    setState(() {
      _data = rows;
      _isLoading = false;
    });
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MeasurementRepository.delete(id);

      if (!mounted) return;

      _load();
    }
  }

  String _formatGroupDate(String isoString) {
    final d = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();

    final pad = (int n) => n.toString().padLeft(2, '0');

    if (d.year == now.year &&
        d.month == now.month &&
        d.day == now.day) {
      return 'Hari ini';
    }

    String dayName;

    switch (d.weekday) {
      case 1:
        dayName = 'Senin';
        break;
      case 2:
        dayName = 'Selasa';
        break;
      case 3:
        dayName = 'Rabu';
        break;
      case 4:
        dayName = 'Kamis';
        break;
      case 5:
        dayName = 'Jumat';
        break;
      case 6:
        dayName = 'Sabtu';
        break;
      case 7:
        dayName = 'Minggu';
        break;
      default:
        dayName = '';
    }

    return '$dayName, ${pad(d.day)}/${pad(d.month)}/${d.year}';
  }

  String _formatItemTime(String isoString) {
    final d = DateTime.parse(isoString).toLocal();

    final pad = (int n) => n.toString().padLeft(2, '0');

    return '${pad(d.hour)}:${pad(d.minute)}';
  }

  (Color, Color) _getStyle(String? status) {
    switch (status) {
      case 'Normal':
        return (
        const Color(0xFFD8F3E1),
        const Color(0xFF2E9E5B),
        );

      case 'Tinggi':
        return (
        const Color(0xFFFFE0D6),
        const Color(0xFFE05A2B),
        );

      case 'Rendah':
        return (
        const Color(0xFFD6ECFA),
        const Color(0xFF1E88E5),
        );

      default:
        return (
        const Color(0xFFEFEFEF),
        const Color(0xFF9E9E9E),
        );
    }
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isBp = widget.type == MeasurementRepository.tekananDarah;

    String valueText = '';

    if (isBp) {
      final sys = (item['value'] as num).toInt();
      final dia = (item['diastolic'] as num).toInt();
      final pulse = (item['pulse'] as num).toInt();

      valueText = '$sys mmHg   $dia mmHg   $pulse BPM';
    } else {
      final val = (item['value'] as num).toInt();

      valueText = '$val mg/dL';
    }

    final status = item['status'] as String;
    final style = _getStyle(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatItemTime(
                          item['created_at'] as String,
                        ),
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: style.$1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: style.$2,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => _confirmDelete(item['id'] as int),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBp = widget.type == MeasurementRepository.tekananDarah;

    final userName = Session.user!['full_name'] as String;

    final grouped = <String, List<Map<String, dynamic>>>{};

    for (var row in _data) {
      final group = _formatGroupDate(
        row['created_at'] as String,
      );

      grouped.putIfAbsent(group, () => []).add(row);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBp ? 'Tekanan Darah' : 'Gula Darah',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () {},
                  child: const Text('7 Hari'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: null,
                  child: const Text('Pilih Periode'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _data.isEmpty
                ? const Center(
              child: Text(
                'Belum ada data',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: grouped.length,
              itemBuilder: (context, i) {
                final groupDate =
                grouped.keys.elementAt(i);

                final items = grouped[groupDate]!;

                return Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                        top: 8,
                      ),
                      child: Text(
                        groupDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ...items.map(
                          (item) => _buildHistoryItem(item),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
