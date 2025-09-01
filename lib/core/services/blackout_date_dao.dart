import 'package:cat_hotel_pos/features/booking/domain/entities/blackout_date.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class BlackoutDateDao {
  static const String _storageKey = 'blackout_dates';

  Future<List<BlackoutDate>> getAll() async {
    final data = await WebStorageService.getData(_storageKey);
    if (data == null) return [];
    
    return (data as List)
        .map((json) => BlackoutDate.fromJson(json))
        .toList();
  }

  Future<BlackoutDate?> getById(String id) async {
    final blackoutDates = await getAll();
    try {
      return blackoutDates.firstWhere((blackout) => blackout.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> insert(BlackoutDate blackoutDate) async {
    final blackoutDates = await getAll();
    blackoutDates.add(blackoutDate);
    WebStorageService.saveData(_storageKey, blackoutDates.map((b) => b.toJson()).toList());
  }

  Future<void> update(BlackoutDate blackoutDate) async {
    final blackoutDates = await getAll();
    final index = blackoutDates.indexWhere((b) => b.id == blackoutDate.id);
    if (index != -1) {
      blackoutDates[index] = blackoutDate;
      WebStorageService.saveData(_storageKey, blackoutDates.map((b) => b.toJson()).toList());
    }
  }

  Future<void> delete(String id) async {
    final blackoutDates = await getAll();
    blackoutDates.removeWhere((blackout) => blackout.id == id);
    WebStorageService.saveData(_storageKey, blackoutDates.map((b) => b.toJson()).toList());
  }

  Future<List<BlackoutDate>> getActiveBlackoutDates() async {
    final blackoutDates = await getAll();
    final now = DateTime.now();
    return blackoutDates.where((blackout) {
      return blackout.isActive &&
             blackout.endDate.isAfter(now);
    }).toList();
  }

  Future<List<BlackoutDate>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final blackoutDates = await getAll();
    return blackoutDates.where((blackout) {
      return blackout.startDate.isBefore(endDate) &&
             blackout.endDate.isAfter(startDate);
    }).toList();
  }

  Future<List<BlackoutDate>> getByRoomId(String roomId) async {
    final blackoutDates = await getAll();
    return blackoutDates.where((blackout) {
      return blackout.affectedRoomIds.contains(roomId);
    }).toList();
  }

  Future<List<BlackoutDate>> getByReason(BlackoutReason reason) async {
    final blackoutDates = await getAll();
    return blackoutDates.where((blackout) => blackout.reason == reason).toList();
  }

  Future<bool> isRoomBlackedOut(String roomId, DateTime date) async {
    final blackoutDates = await getByRoomId(roomId);
    return blackoutDates.any((blackout) {
      return blackout.isActive &&
             blackout.startDate.isBefore(date.add(const Duration(days: 1))) &&
             blackout.endDate.isAfter(date.subtract(const Duration(days: 1)));
    });
  }
}
