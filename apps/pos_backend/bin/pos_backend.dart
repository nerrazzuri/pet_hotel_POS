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

  // In-memory stores (dev only)
  final List<Map<String, dynamic>> bookings = [];
  final List<Map<String, dynamic>> payments = [];
  final List<Map<String, dynamic>> deposits = [];
  final List<Map<String, dynamic>> waitlist = [];
  final List<Map<String, dynamic>> blackoutDates = [];
  // Simple rate rule toggles (could be expanded later)
  double weekendMultiplier = 1.1;
  double seasonalMultiplier = 1.0;

  // Auth helper
  Map<String, dynamic>? _verifyJwt(String? authHeader) {
    if (authHeader == null || !authHeader.startsWith('Bearer ')) return null;
    final token = authHeader.substring('Bearer '.length);
    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

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
    // Check blackout overlap (very simple overlap check)
    bool blocked = blackoutDates.any((b) {
      final bs = DateTime.tryParse(b['start']?.toString() ?? '');
      final be = DateTime.tryParse(b['end']?.toString() ?? '');
      final rt = (b['roomType']?.toString() ?? roomType);
      if (bs == null || be == null) return false;
      if (rt != roomType) return false;
      return !(end.isBefore(bs) || start.isAfter(be));
    });
    if (blocked) {
      return _json({
        'available': false,
        'reason': 'blackout',
      });
    }
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
    final booking = {
      'id': id,
      'status': 'pending',
      'data': body,
      'createdAt': DateTime.now().toIso8601String(),
    };
    bookings.add(booking);
    return _json({'bookingId': id, 'status': 'pending'});
  });

  // Deposit payment
  router.post('/payments/deposit', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final id = uuid.v4();
    final bookingId = body['bookingId']?.toString();
    final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
    final deposit = {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'status': 'authorized',
      'createdAt': DateTime.now().toIso8601String(),
    };
    deposits.add(deposit);
    payments.add({'id': id, 'type': 'deposit', 'amount': amount, 'bookingId': bookingId});
    return _json({'paymentId': id, 'status': 'authorized'});
  });

  // Apply deposit at checkout
  router.post('/payments/apply', (Request req) async {
    final body = req.context['json'] as Map<String, dynamic>? ?? {};
    final bookingId = body['bookingId']?.toString();
    final applicable = deposits.where((d) => d['bookingId'] == bookingId && d['status'] == 'authorized').toList();
    final appliedTotal = applicable.fold<double>(0.0, (acc, d) => acc + ((d['amount'] as num?)?.toDouble() ?? 0.0));
    for (final d in applicable) {
      d['status'] = 'applied';
    }
    final booking = bookings.firstWhere((b) => b['id'] == bookingId, orElse: () => {});
    booking['depositApplied'] = appliedTotal;
    return _json({'bookingId': bookingId, 'applied': appliedTotal});
  });

  // Policies/FAQs/Reviews
  router.get('/policies', (Request req) => _json({'items': ['Vaccination required', 'Late checkout fees may apply']}));
  router.get('/faqs', (Request req) => _json({'items': ['What are check-in times?', 'How are pets fed?']}));
  router.get('/reviews', (Request req) => _json({'items': [
        {'author': 'Alice', 'rating': 5, 'comment': 'Great stay!'},
        {'author': 'Ben', 'rating': 4, 'comment': 'Clean and friendly.'},
      ]}));

  // Admin (protected) endpoints
  Response _requireAuth(Request req, Response Function(Map<String, dynamic>) handler) {
    final payload = _verifyJwt(req.headers['authorization']);
    if (payload == null) return _json({'error': 'unauthorized'}, status: 401);
    return handler(payload);
  }

  router.get('/admin/bookings', (Request req) => _requireAuth(req, (_) => _json({'items': bookings})));
  router.get('/admin/payments', (Request req) => _requireAuth(req, (_) => _json({'items': payments})));
  router.get('/admin/deposits', (Request req) => _requireAuth(req, (_) => _json({'items': deposits})));

  router.post('/admin/blackouts', (Request req) async {
    return _requireAuth(req, (_) {
      final body = req.context['json'] as Map<String, dynamic>? ?? {};
      final entry = {
        'id': uuid.v4(),
        'start': body['start'],
        'end': body['end'],
        'roomType': body['roomType'] ?? 'standard',
        'reason': body['reason'] ?? 'maintenance',
      };
      blackoutDates.add(entry);
      return _json({'ok': true, 'id': entry['id']});
    });
  });
  router.get('/admin/blackouts', (Request req) => _requireAuth(req, (_) => _json({'items': blackoutDates})));

  router.post('/admin/waitlist', (Request req) async {
    return _requireAuth(req, (_) {
      final body = req.context['json'] as Map<String, dynamic>? ?? {};
      final entry = {
        'id': uuid.v4(),
        'customer': body['customer'],
        'pet': body['pet'],
        'requestedRange': body['requestedRange'],
        'roomType': body['roomType'] ?? 'standard',
        'createdAt': DateTime.now().toIso8601String(),
      };
      waitlist.add(entry);
      return _json({'ok': true, 'id': entry['id']});
    });
  });
  router.get('/admin/waitlist', (Request req) => _requireAuth(req, (_) => _json({'items': waitlist})));

  router.post('/admin/rules/rates', (Request req) async {
    return _requireAuth(req, (_) {
      final body = req.context['json'] as Map<String, dynamic>? ?? {};
      weekendMultiplier = (body['weekendMultiplier'] as num?)?.toDouble() ?? weekendMultiplier;
      seasonalMultiplier = (body['seasonalMultiplier'] as num?)?.toDouble() ?? seasonalMultiplier;
      return _json({'ok': true, 'weekendMultiplier': weekendMultiplier, 'seasonalMultiplier': seasonalMultiplier});
    });
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(_jsonDecodeMiddleware())
      .addHandler(router);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8081;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('POS backend running on http://localhost:${server.port}');
}
