import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8081');

  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Map<String, dynamic>>> getRoomTypes() async {
    final resp = await http.get(_uri('/rooms/types'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final List list = data['types'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch room types: ${resp.statusCode} ${resp.body}');
  }

  Future<List<String>> getPolicies() async {
    final resp = await http.get(_uri('/policies'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final List list = data['items'] as List? ?? [];
      return list.cast<String>();
    }
    throw Exception('Failed to fetch policies');
  }

  Future<List<String>> getFaqs() async {
    final resp = await http.get(_uri('/faqs'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final List list = data['items'] as List? ?? [];
      return list.cast<String>();
    }
    throw Exception('Failed to fetch FAQs');
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    final resp = await http.get(_uri('/reviews'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final List list = data['items'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch reviews');
  }

  Future<Map<String, dynamic>> availabilityQuote({required DateTime start, required DateTime end, required int petCount, required String petType, required String roomType}) async {
    final resp = await http.post(
      _uri('/availability/quote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'petCount': petCount,
        'petType': petType,
        'roomType': roomType,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Quote failed: ${resp.statusCode} ${resp.body}');
  }
}


