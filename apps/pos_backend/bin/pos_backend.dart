import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

const jwtSecret = 'dev-secret-change-me';
final uuid = Uuid();

Response _json(Object data, {int status = 200}) => Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Middleware _jsonDecodeMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'POST' || request.method == 'PUT' || request.method == 'PATCH') {
        final body = await request.readAsString();
        final decoded = body.isEmpty ? {} : jsonDecode(body);
        final updated = request.change(context: {'json': decoded});
        return innerHandler(updated);
      }
      return innerHandler(request);
    };
  };
}

void main(List<String> arguments) async {
  final router = Router();

  // Auth
  router.post('/auth/login', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final username = body['username']?.toString() ?? '';
    final password = body['password']?.toString() ?? '';
    if (username.isEmpty || password.isEmpty) {
      return _json({'error': 'invalid_credentials'}, status: 401);
    }
    final jwt = JWT({'sub': username, 'role': 'owner'});
    final token = jwt.sign(SecretKey(jwtSecret), expiresIn: const Duration(hours: 8));
    return _json({'token': token});
  });

  // Room types
  router.get('/rooms/types', (Request req) async {
    return _json({
      'types': [
        {'code': 'standard', 'name': 'Standard', 'basePrice': 45.0},
        {'code': 'deluxe', 'name': 'Deluxe', 'basePrice': 65.0},
        {'code': 'suite', 'name': 'Suite', 'basePrice': 85.0},
      ]
    });
  });

  // Availability quote
  router.post('/availability/quote', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final start = DateTime.tryParse(body['start'] ?? '') ?? DateTime.now();
    final end = DateTime.tryParse(body['end'] ?? '') ?? start.add(const Duration(days: 1));
    final nights = end.difference(start).inDays.clamp(1, 365);
    final petCount = (body['petCount'] ?? 1) as int;
    final roomType = (body['roomType'] ?? 'standard') as String;
    final base = switch (roomType) {
      'suite' => 85.0,
      'deluxe' => 65.0,
      _ => 45.0,
    };
    final weekendMultiplier = 1.1;
    final seasonalMultiplier = 1.0; // TODO seasonal rules
    final pricePerNight = (base * weekendMultiplier * seasonalMultiplier).toStringAsFixed(2);
    final total = (double.parse(pricePerNight) * nights * petCount).toStringAsFixed(2);
    return _json({
      'available': true,
      'nights': nights,
      'price': {'perNight': pricePerNight, 'total': total},
      'rateBreakdown': {
        'base': base,
        'weekendMultiplier': weekendMultiplier,
        'seasonalMultiplier': seasonalMultiplier,
      }
    });
  });

  // Create booking
  router.post('/bookings', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final id = uuid.v4();
    return _json({'bookingId': id, 'status': 'pending', 'data': body});
  });

  // Deposit payment
  router.post('/payments/deposit', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final id = uuid.v4();
    return _json({'paymentId': id, 'status': 'authorized', 'data': body});
  });

  // Policies/FAQs/Reviews
  router.get('/policies', (Request req) => _json({'items': ['Vaccination required', 'Late checkout fees may apply']}));
  router.get('/faqs', (Request req) => _json({'items': ['What are check-in times?', 'How are pets fed?']}));
  router.get('/reviews', (Request req) => _json({'items': [
        {'author': 'Alice', 'rating': 5, 'comment': 'Great stay!'},
        {'author': 'Ben', 'rating': 4, 'comment': 'Clean and friendly.'},
      ]}));

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(_jsonDecodeMiddleware())
      .addHandler(router);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8081;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('POS backend running on http://localhost:${server.port}');
}
