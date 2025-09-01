import 'package:cat_hotel_pos/features/booking/domain/entities/waitlist.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class WaitlistDao {
  static const String _storageKey = 'waitlist_entries';

  Future<List<WaitlistEntry>> getAll() async {
    final data = await WebStorageService.getData(_storageKey);
    if (data == null) return [];
    
    return (data as List)
        .map((json) => WaitlistEntry.fromJson(json))
        .toList();
  }

  Future<WaitlistEntry?> getById(String id) async {
    final entries = await getAll();
    try {
      return entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> insert(WaitlistEntry entry) async {
    final entries = await getAll();
    entries.add(entry);
    WebStorageService.saveData(_storageKey, entries.map((e) => e.toJson()).toList());
  }

  Future<void> update(WaitlistEntry entry) async {
    final entries = await getAll();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      WebStorageService.saveData(_storageKey, entries.map((e) => e.toJson()).toList());
    }
  }

  Future<void> delete(String id) async {
    final entries = await getAll();
    entries.removeWhere((entry) => entry.id == id);
    WebStorageService.saveData(_storageKey, entries.map((e) => e.toJson()).toList());
  }

  Future<List<WaitlistEntry>> getByStatus(WaitlistStatus status) async {
    final entries = await getAll();
    return entries.where((entry) => entry.status == status).toList();
  }

  Future<List<WaitlistEntry>> getByPriority(WaitlistPriority priority) async {
    final entries = await getAll();
    return entries.where((entry) => entry.priority == priority).toList();
  }

  Future<List<WaitlistEntry>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final entries = await getAll();
    return entries.where((entry) {
      return entry.requestedCheckInDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entry.requestedCheckInDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<List<WaitlistEntry>> getByRoomType(RoomType roomType) async {
    final entries = await getAll();
    return entries.where((entry) => entry.preferredRoomType == roomType).toList();
  }

  Future<List<WaitlistEntry>> getExpiredEntries() async {
    final entries = await getAll();
    final now = DateTime.now();
    return entries.where((entry) {
      return entry.status == WaitlistStatus.pending &&
             entry.requestedCheckInDate.isBefore(now);
    }).toList();
  }
}
