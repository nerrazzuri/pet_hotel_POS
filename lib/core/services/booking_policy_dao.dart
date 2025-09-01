import 'package:cat_hotel_pos/features/booking/domain/entities/booking_policy.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class BookingPolicyDao {
  static const String _storageKey = 'booking_policies';

  Future<List<BookingPolicy>> getAll() async {
    final data = await WebStorageService.getData(_storageKey);
    if (data == null) return [];
    
    return (data as List)
        .map((json) => BookingPolicy.fromJson(json))
        .toList();
  }

  Future<BookingPolicy?> getById(String id) async {
    final policies = await getAll();
    try {
      return policies.firstWhere((policy) => policy.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> insert(BookingPolicy policy) async {
    final policies = await getAll();
    policies.add(policy);
    WebStorageService.saveData(_storageKey, policies.map((p) => p.toJson()).toList());
  }

  Future<void> update(BookingPolicy policy) async {
    final policies = await getAll();
    final index = policies.indexWhere((p) => p.id == policy.id);
    if (index != -1) {
      policies[index] = policy;
      WebStorageService.saveData(_storageKey, policies.map((p) => p.toJson()).toList());
    }
  }

  Future<void> delete(String id) async {
    final policies = await getAll();
    policies.removeWhere((policy) => policy.id == id);
    WebStorageService.saveData(_storageKey, policies.map((p) => p.toJson()).toList());
  }

  Future<List<BookingPolicy>> getActivePolicies() async {
    final policies = await getAll();
    return policies.where((policy) => policy.isActive).toList();
  }

  Future<BookingPolicy?> getByType(PolicyType type) async {
    final policies = await getActivePolicies();
    try {
      return policies.firstWhere((policy) => policy.type == type);
    } catch (e) {
      return null;
    }
  }

  Future<List<BookingPolicy>> getByTypes(List<PolicyType> types) async {
    final policies = await getActivePolicies();
    return policies.where((policy) => types.contains(policy.type)).toList();
  }
}
