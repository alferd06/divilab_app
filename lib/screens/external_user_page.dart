import 'package:flutter/material.dart';
import '../models/external_user.dart';
import '../services/user_api.dart';

class ExternalUserPage extends StatefulWidget {
  const ExternalUserPage({super.key});
  @override
  State<ExternalUserPage> createState() => _ExternalUserPageState();
}

class _ExternalUserPageState extends State<ExternalUserPage> {
  late Future<List<ExternalUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = UserApi.fetchUsers(); // dibuat SEKALI di sini, bukan di build()
  }

  void _retry() {
    setState(() {
      _future = UserApi.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List User External')),
      body: FutureBuilder<List<ExternalUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat data. Periksa koneksi internet.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _retry, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(u.image),
                  onBackgroundImageError: (_, __) {},
                ),
                title: Text(u.fullName),
                subtitle: Text(u.email),
              );
            },
          );
        },
      ),
    );
  }
}