import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/measurement_repository.dart';

class ReportPdf {
  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _dateTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return '${_pad(d.day)}/${_pad(d.month)}/${d.year} ${_pad(d.hour)}:${_pad(d.minute)}';
  }

  static pw.Widget _section(
      String title,
      List<String> headers,
      List<List<String>> rows,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        if (rows.isEmpty)
          pw.Text('Belum ada data')
        else
          pw.TableHelper.fromTextArray(headers: headers, data: rows),
      ],
    );
  }

  static Future<void> open({
    required int userId,
    required String userName,
  }) async {
    const week = Duration(days: 7);
    final glucose = await MeasurementRepository.listByType(
        userId, MeasurementRepository.glucose,
        within: week);
    final bp = await MeasurementRepository.listByType(
        userId, MeasurementRepository.tekananDarah,
        within: week);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('Laporan Pengukuran DiViLab',
              style:
              pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Pasien: $userName'),
          pw.Text('Periode: 7 hari terakhir'),
          _section(
            'Gula Darah',
            ['Waktu', 'Nilai (mg/dL)', 'Status'],
            glucose
                .map((r) => [
              _dateTime(r['created_at'] as String),
              (r['value'] as num).toStringAsFixed(0),
              r['status'] as String,
            ])
                .toList(),
          ),
          _section(
            'Tekanan Darah',
            ['Waktu', 'Sistolik', 'Diastolik', 'Nadi (BPM)', 'Status'],
            bp
                .map((r) => [
              _dateTime(r['created_at'] as String),
              (r['value'] as num).toStringAsFixed(0),
              (r['diastolic'] as num).toStringAsFixed(0),
              '${r['pulse']}',
              r['status'] as String,
            ])
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'laporan_divilab.pdf',
      onLayout: (_) async => doc.save(),
    );
  }
}