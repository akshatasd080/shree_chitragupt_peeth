import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../../data/services/auth_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Lightweight HTTP client used by all content services.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    final params = Map<String, String>.from(query ?? {});
    params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    return Uri.parse('$base$normalized').replace(queryParameters: params);
  }

  Future<Map<String, String>> _headers({bool jsonBody = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    try {
      final response = await _client
          .get(
            _uri(path, query),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 25));

      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: await _headers(jsonBody: true),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 25));

      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filePath,
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      request.headers.addAll(await _headers());
      request.fields.addAll(fields);

      if (fileField != null && filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            filePath,
            filename: fileName,
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    final message = json['message']?.toString() ??
        'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  void close() => _client.close();
}
