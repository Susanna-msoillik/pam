import 'package:flutter/material.dart';

import '../widgets/confirmation.dart';

import 'package:provider/provider.dart';

import '../data/app_user.dart';
import '../models/auth_model.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfilePage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser>();
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
            user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(user.email, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('CarPool'),
            subtitle: Text('Поездки вместе со студентами'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              if (await confirmAction(context, 'Выйти из аккаунта?') &&
                  context.mounted) {
                await context.read<AuthModel>().logout();
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
