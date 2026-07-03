import 'dart:convert';

import 'package:http/http.dart' as http;

import 'json_placeholder_user.dart';

class JsonPlaceholderApi {
  JsonPlaceholderApi({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  /// Fetches users by id from JSONPlaceholder (ids 1–10 available).
  Future<List<JsonPlaceholderUser>> fetchUsersByIds(List<int> ids) async {
    final users = <JsonPlaceholderUser>[];

    for (final id in ids) {
      final response = await _client.get(Uri.parse('$_baseUrl/users/$id'));
      if (response.statusCode != 200) {
        throw JsonPlaceholderApiException(
          'Failed to load user $id (${response.statusCode})',
        );
      }

      users.add(
        JsonPlaceholderUser.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        ),
      );
    }

    return users;
  }

  void dispose() => _client.close();
}

class JsonPlaceholderApiException implements Exception {
  JsonPlaceholderApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
