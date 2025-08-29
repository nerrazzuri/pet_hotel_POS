import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

enum RoomType {
  standard,
  deluxe,
  vip,
  isolation,
  medical,
  family,
  outdoor,
  playroom
}

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.standard:
        return 'Standard';
      case RoomType.deluxe:
        return 'Deluxe';
      case RoomType.vip:
        return 'VIP';
      case RoomType.isolation:
        return 'Isolation';
      case RoomType.medical:
        return 'Medical';
      case RoomType.family:
        return 'Family';
      case RoomType.outdoor:
        return 'Outdoor';
      case RoomType.playroom:
        return 'Playroom';
    }
  }
}

enum RoomStatus {
  available,
  occupied,
  reserved,
  maintenance,
  cleaning,
  outOfService
}

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String roomNumber,
    required String name,
    required RoomType type,
    required RoomStatus status,
    required int capacity,
    required double basePricePerNight,
    required double peakSeasonPrice,
    required String description,
    required List<String> amenities,
    required Map<String, dynamic> specifications,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? currentOccupantId,
    String? currentOccupantName,
    DateTime? lastCleanedAt,
    DateTime? nextCleaningDue,
    String? notes,
    String? maintenanceNotes,
    double? currentPrice,
    List<String>? images,
    Map<String, dynamic>? metadata,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
class RoomSpecification with _$RoomSpecification {
  const factory RoomSpecification({
    required double width,
    required double length,
    required double height,
    required bool hasWindow,
    required bool hasHeating,
    required bool hasAC,
    required bool hasPlayArea,
    required bool isSoundproofed,
    required bool hasSecurityCamera,
    required int maxPetWeight,
    required List<String> allowedPetTypes,
    required bool isWheelchairAccessible,
    required bool hasEmergencyExit,
    String? specialEquipment,
    Map<String, dynamic>? additionalFeatures,
  }) = _RoomSpecification;

  factory RoomSpecification.fromJson(Map<String, dynamic> json) =>
      _$RoomSpecificationFromJson(json);
}
