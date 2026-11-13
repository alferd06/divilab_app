import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/external_user.dart';

class UserApi {
  static const _url = 'https://dummyjson.com/users';

  static Future<List<ExternalUser>> fetchUsers() async {
    final res =
    await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data (kode ${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['users'] as List)
        .map((e) => ExternalUser.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }
}