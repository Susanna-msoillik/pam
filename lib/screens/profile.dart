import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfilePage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person_outline, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentUserName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('susanna@example.com', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('CarPool'),
            subtitle: Text('Поездки вместе со студентами'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onLogout ?? () {},
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
