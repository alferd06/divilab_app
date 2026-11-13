import 'package:flutter/material.dart';
import 'data/database_helper.dart';
import 'screens/home_shell.dart';
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';

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
      theme: buildAppTheme(),
      home: const SplashPage(),
    );
  }
}