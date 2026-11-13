import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class UserRepository {
  static String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  static Future<bool> emailExists(String email) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
        limit: 1);
    return rows.isNotEmpty;
  }

  static Future<int> register({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    required String birthDate,
    required double heightCm,
    required double weightKg,
    required String productCode,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('users', {
      'email': email.trim().toLowerCase(),
      'password_hash': hashPassword(password),
      'full_name': fullName.trim(),
      'gender': gender,
      'birth_date': birthDate,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'product_code': productCode.trim(),
    });
    debugPrint('users: ${await db.query('users')}'); // bukti AC, hapus setelah dicek
    return id;
  }
}