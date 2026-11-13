import 'dart:async';
import 'package:flutter/material.dart';

Future<void> showStripCountdownDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _StripCountdownDialog(),
  );
}

class _StripCountdownDialog extends StatefulWidget {
  const _StripCountdownDialog();
  @override
  State<_StripCountdownDialog> createState() => _StripCountdownDialogState();
}

class _StripCountdownDialogState extends State<_StripCountdownDialog> {
  static const _total = 7;
  int _remaining = _total;
  bool _ready = false;
  Timer? _timer;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        t.cancel();
        setState(() => _ready = true);
        _closeTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _closeTimer?.cancel(); // wajib, sama seperti di ST-06
    super.dispose();
  }

  Widget _countdownBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'Strip sudah '),
              TextSpan(text: 'dicabut', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Alat sedang bersiap untuk pengukuran berikutnya.',
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: _remaining / _total,
                  strokeWidth: 10,
                  backgroundColor: const Color(0xFFE6E6E6),
                  color: const Color(0xFF039BE5),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_remaining',
                      style: const TextStyle(
                          fontSize: 56, fontWeight: FontWeight.bold)),
                  const Text('Detik', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F3FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Mohon menunggu hingga hitungan selesai\nsebelum memasang '),
                TextSpan(
                    text: 'strip baru',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _readyBody() {
    const green = Color(0xFF2E9E5B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Alat siap dipakai',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Silakan pasang strip berikutnya.'),
        const SizedBox(height: 24),
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB7E4C7), width: 10),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 72, color: green),
              Text('Selesai',
                  style: TextStyle(
                      color: green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3E4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Layar ini akan menutup otomatis.',
              textAlign: TextAlign.center),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // blokir tombol back selama dialog tampil
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _ready ? _readyBody() : _countdownBody(),
        ),
      ),
    );
  }
}