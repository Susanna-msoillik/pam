import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'result.dart';
import 'token_store.dart';

class HttpApi {
  final String baseUrl;
  final TokenStore tokens;
  final Future<void> Function() onUnauthorized;
  final http.Client _client;
  HttpApi(
    this.baseUrl,
    this.tokens, {
    required this.onUnauthorized,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Result<T>> request<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    try {
      final token = authenticated ? await tokens.read() : null;
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final request = http.Request(method, uri)
        ..headers['Accept'] = 'application/json';
      if (authenticated) {
        request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      }
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 401 && authenticated) {
        if (await tokens.read() == token) {
          await tokens.clear();
          await onUnauthorized();
        }
        return const Err('Сессия завершена. Войдите снова');
      }
      final data = response.statusCode == 204
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Err(_message(response.statusCode, data));
      }
      return Ok(parse(data));
    } on SocketException {
      return const Err('Не удалось соединиться с сервером');
    } on http.ClientException {
      return const Err('Соединение с сервером прервано');
    } on TimeoutException {
      return const Err('Сервер не ответил вовремя');
    } on FormatException {
      return const Err('Сервер вернул некорректные данные');
    } on TypeError {
      return const Err('Сервер вернул некорректные данные');
    }
  }

  String _message(int status, Map<String, dynamic> data) {
    final error = data['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String?;
    if (message != null && RegExp('[А-Яа-яЁё]').hasMatch(message)) {
      return message;
    }
    return switch (status) {
      401 => 'Неверный e-mail или пароль',
      404 => 'Запись не найдена',
      409 =>
        error?['code'] == 'EMAIL_TAKEN'
            ? 'Этот e-mail уже зарегистрирован'
            : 'Данные изменились. Обновите список',
      400 => 'Проверьте введённые данные',
      _ => 'Ошибка сервера. Попробуйте позже',
    };
  }

  void close() => _client.close();
}
