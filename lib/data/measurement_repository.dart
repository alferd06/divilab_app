
import 'database_helper.dart';

class MeasurementRepository {
  static const glucose = 'gula_darah';
  static const tekananDarah = 'tekanan_darah';

  // Ambang: <70 Rendah, 70-140 Normal, >140 Tinggi.
  static String glucoseStatus(double v) {
    if (v < 70) return 'Rendah';
    if (v <= 140) return 'Normal';
    return 'Tinggi';
  }

  static String tekananDarahStatus(double systolic) {
    if (systolic < 90) return 'Rendah';
    if (systolic <= 139) return 'Normal';
    return 'Tinggi';
  }

  static Future<int> insert({
    required int userId,
    required String type,
    required double value,
    required String unit,
    required String status,
    double? diastolic,
    int? pulse,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return db.insert('measurements', {
      'user_id': userId,
      'type': type,
      'value': value,
      'unit': unit,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
      if (diastolic != null) 'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
    });
  }

  static Future<Map<String, dynamic>?> latest(
      int userId,
      String type,
      ) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'measurements',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return Map<String, dynamic>.from(rows.first);
  }

  static Future<List<Map<String, dynamic>>> listByType(
      int userId,
      String type, {
        Duration? within,
      }) async {
    final db = await DatabaseHelper.instance.database;

    String whereStr = 'user_id = ? AND type = ?';
    List<Object> args = [userId, type];

    if (within != null) {
      final cutoff = DateTime.now()
          .subtract(within)
          .toIso8601String();

      whereStr += ' AND created_at >= ?';
      args.add(cutoff);
    }

    final rows = await db.query(
      'measurements',
      where: whereStr,
      whereArgs: args,
      orderBy: 'created_at DESC',
    );

    return rows
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
