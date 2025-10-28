import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://178.63.171.244:8000';

class ApiService {
  Future<bool> authenticate(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getSettings(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/settings?user_id=$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  Future<void> saveSettings(String userId, Map<String, dynamic> data) async {
    try {
      final payload = {
        'user_id': userId,
        'timeframes': data['timeframes'],
        'modes': data['modes'],
        'sessions': data['sessions'],
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/settings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) throw Exception('Save failed');
    } catch (e) {
      throw Exception('Network error');
    }
  }

  Future<List<dynamic>> getAlerts(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/alerts?user_id=$userId'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<dynamic>.from(body['alerts']);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  String getImageUrl(String filename) {
    return '$_baseUrl/image/$filename';
  }
}
