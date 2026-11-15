import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final success = await context.read<AuthModel>().signIn(
      _email.text.trim(),
      _password.text,
      name: _register ? _name.text.trim() : null,
    );
    if (mounted && success) context.go('/routes');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CarPool')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(
          key: _form,
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
                _register ? 'Создать аккаунт' : 'Едем вместе',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              if (_register) ...[
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите имя' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                        .hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Введите корректный e-mail',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
                validator: (v) =>
                    (v?.length ?? 0) >= 6 ? null : 'Минимум 6 символов',
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              if (context.watch<AuthModel>().error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    context.watch<AuthModel>().error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: context.watch<AuthModel>().loading ? null : _submit,
                child: Text(_register ? 'Зарегистрироваться' : 'Войти'),
              ),
              TextButton(
                onPressed: context.watch<AuthModel>().loading
                    ? null
                    : () => setState(() {
                        _register = !_register;
                        _form.currentState?.reset();
                      }),
                child: Text(
                  _register ? 'Уже есть аккаунт? Войти' : 'Создать аккаунт',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
