import 'package:cat_hotel_pos/features/pos/domain/entities/payment.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class PaymentDao {
  static const String _collectionName = 'payments';

  PaymentDao();

  Future<List<Payment>> getAll() async {
    try {
      final data = WebStorageService.getData(_collectionName);
      return data.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Payment?> getById(String id) async {
    try {
      final data = WebStorageService.getData(_collectionName);
      final paymentData = data.firstWhere(
        (item) => item['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      if (paymentData.isNotEmpty) {
        return Payment.fromJson(paymentData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> create(Payment payment) async {
    final existingData = WebStorageService.getData(_collectionName);
    existingData.add(payment.toJson());
    WebStorageService.saveData(_collectionName, existingData);
  }

  Future<void> update(Payment payment) async {
    final existingData = WebStorageService.getData(_collectionName);
    final index = existingData.indexWhere((item) => item['id'] == payment.id);
    if (index >= 0) {
      existingData[index] = payment.toJson();
      WebStorageService.saveData(_collectionName, existingData);
    }
  }

  Future<void> delete(String id) async {
    final existingData = WebStorageService.getData(_collectionName);
    existingData.removeWhere((item) => item['id'] == id);
    WebStorageService.saveData(_collectionName, existingData);
  }

  Future<List<Payment>> getPaymentsByBookingId(String bookingId) async {
    try {
      final allPayments = await getAll();
      return allPayments.where((payment) => payment.bookingId == bookingId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Payment>> getDepositsByBookingId(String bookingId) async {
    try {
      final allPayments = await getAll();
      return allPayments.where((payment) => 
        payment.bookingId == bookingId && 
        payment.paymentType == PaymentType.deposit
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Payment>> getPaymentsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allPayments = await getAll();
      return allPayments.where((payment) => 
        payment.processedAt.isAfter(startDate) && 
        payment.processedAt.isBefore(endDate)
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Payment>> getPaymentsByCustomer(String customerName) async {
    try {
      final allPayments = await getAll();
      return allPayments.where((payment) => 
        payment.customerName.toLowerCase().contains(customerName.toLowerCase())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalPaymentsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final payments = await getPaymentsByDateRange(startDate, endDate);
      return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    } catch (e) {
      return 0.0;
    }
  }
}
