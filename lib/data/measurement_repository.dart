import 'database_helper.dart';

class MeasurementRepository {
  static const glucose = 'gula_darah';

  /// Ambang dari Asumsi: <70 Rendah, 70-140 Normal, >140 Tinggi.
  static String glucoseStatus(double v) {
    if (v < 70) return 'Rendah';
    if (v <= 140) return 'Normal';
    return 'Tinggi';
  }

  static Future<int> insert({
    required int userId,
    required String type,
    required double value,
    required String unit,
    required String status,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('measurements', {
      'user_id': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, Object?>?> latest(int userId, String type) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'measurements',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'id DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }
}