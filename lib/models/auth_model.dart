import 'package:flutter/foundation.dart';

import '../data/app_user.dart';
import '../data/http_api.dart';
import '../data/result.dart';
import '../data/token_store.dart';

class AuthModel extends ChangeNotifier {
  final HttpApi api;
  final TokenStore tokens;
  AuthModel(this.api, this.tokens, {required this.authenticated});
  bool authenticated;
  AppUser? user;
  bool loading = false;
  String? error;
  int _generation = 0;

  Future<void> restore() async {
    if (loading) return;
    final generation = ++_generation;
    loading = true;
    error = null;
    notifyListeners();
    final result = await api.request('GET', '/me', AppUser.fromJson);
    if (generation != _generation) return;
    switch (result) {
      case Ok(value: final value):
        user = value;
      case Err(message: final message):
        error = message;
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password, {String? name}) async {
    if (loading) return false;
    final generation = ++_generation;
    loading = true;
    error = null;
    notifyListeners();
    final result = await api.request(
      'POST',
      name == null ? '/auth/login' : '/auth/register',
      (data) => (
        data['token'] as String,
        AppUser.fromJson(data['user'] as Map<String, dynamic>),
      ),
      authenticated: false,
      body: {'email': email, 'password': password, 'name': ?name},
    );
    if (generation != _generation) return false;
    switch (result) {
      case Ok(value: final value):
        await tokens.save(value.$1);
        user = value.$2;
        authenticated = true;
      case Err(message: final message):
        error = message;
    }
    loading = false;
    notifyListeners();
    return user != null;
  }

  Future<void> logout() async {
    ++_generation;
    await tokens.clear();
    user = null;
    authenticated = false;
    loading = false;
    error = null;
    notifyListeners();
  }
}
