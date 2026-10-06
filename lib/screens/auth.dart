import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  final VoidCallback onLogin;
  const AuthPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CarPool')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.directions_car,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Едем вместе',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Пароль'),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: onLogin, child: const Text('Войти')),
              TextButton(
                onPressed: () {},
                child: const Text('Создать аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
