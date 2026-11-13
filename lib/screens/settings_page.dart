import 'package:flutter/material.dart';
import 'external_user_page.dart';
import '../services/session.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('List User External'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExternalUserPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Session.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}