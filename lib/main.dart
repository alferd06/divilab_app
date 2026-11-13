import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.instance.database;
  final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'");
  runApp(const DiviLabApp());
}

class DiviLabApp extends StatelessWidget {
  const DiviLabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiViLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A6E8)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}