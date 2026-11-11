import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString('token');
  Future<void> save(String token) async {
    await (await SharedPreferences.getInstance()).setString('token', token);
  }

  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove('token');
  }
}
