import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'incident.freezed.dart';
part 'incident.g.dart';

@JsonEnum()
enum IncidentType {
  @JsonValue('medical')
  medical,
  @JsonValue('behavioral')
  behavioral,
  @JsonValue('accident')
  accident,
  @JsonValue('injury')
  injury,
  @JsonValue('escape')
  escape,
  @JsonValue('aggression')
  aggression,
  @JsonValue('anxiety')
  anxiety,
  @JsonValue('dietary')
  dietary,
  @JsonValue('other')
  other,
}

@JsonEnum()
enum IncidentSeverity {
  @JsonValue('minor')
  minor,
  @JsonValue('moderate')
  moderate,
  @JsonValue('major')
  major,
  @JsonValue('critical')
  critical,
}

@JsonEnum()
enum IncidentStatus {
  @JsonValue('reported')
  reported,
  @JsonValue('investigating')
  investigating,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
  @JsonValue('escalated')
  escalated,
}

@freezed
class Incident with _$Incident {
  const factory Incident({
    required String id,
    required String customerId,
    required String customerName,
    required String petId,
    required String petName,
    required IncidentType type,
    required IncidentSeverity severity,
    required IncidentStatus status,
    required String title,
    required String description,
    required DateTime reportedDate,
    required String reportedBy,
    DateTime? occurredDate,
    DateTime? resolvedDate,
    String? location,
    String? witnesses,
    String? actionsTaken,
    String? followUpRequired,
    String? notes,
    List<String>? attachments,
    bool? requiresVeterinarian,
    bool? requiresCustomerNotification,
    bool? blocksCheckIn,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Incident;

  factory Incident.fromJson(Map<String, dynamic> json) => _$IncidentFromJson(json);
}

extension IncidentExtension on Incident {
  bool get isOpen => status == IncidentStatus.reported || status == IncidentStatus.investigating;
  bool get isResolved => status == IncidentStatus.resolved || status == IncidentStatus.closed;
  bool get isCritical => severity == IncidentSeverity.critical;
  bool get needsFollowUp => followUpRequired != null && followUpRequired!.isNotEmpty;
  
  String get severityDisplay {
    switch (severity) {
      case IncidentSeverity.minor:
        return 'Minor';
      case IncidentSeverity.moderate:
        return 'Moderate';
      case IncidentSeverity.major:
        return 'Major';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }
  
  Color get severityColor {
    switch (severity) {
      case IncidentSeverity.minor:
        return Colors.green;
      case IncidentSeverity.moderate:
        return Colors.orange;
      case IncidentSeverity.major:
        return Colors.red;
      case IncidentSeverity.critical:
        return Colors.purple;
    }
  }
  
  String get statusDisplay {
    switch (status) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.investigating:
        return 'Investigating';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.closed:
        return 'Closed';
      case IncidentStatus.escalated:
        return 'Escalated';
    }
  }
  
  String get typeDisplay {
    switch (type) {
      case IncidentType.medical:
        return 'Medical';
      case IncidentType.behavioral:
        return 'Behavioral';
      case IncidentType.accident:
        return 'Accident';
      case IncidentType.injury:
        return 'Injury';
      case IncidentType.escape:
        return 'Escape';
      case IncidentType.aggression:
        return 'Aggression';
      case IncidentType.anxiety:
        return 'Anxiety';
      case IncidentType.dietary:
        return 'Dietary';
      case IncidentType.other:
        return 'Other';
    }
  }
  
  int get daysSinceReported {
    final now = DateTime.now();
    return now.difference(reportedDate).inDays;
  }
  
  int get daysSinceOccurred {
    if (occurredDate == null) return -1;
    final now = DateTime.now();
    return now.difference(occurredDate!).inDays;
  }
  
  bool get isRecent => daysSinceReported <= 7;
  bool get isUrgent => severity == IncidentSeverity.critical || severity == IncidentSeverity.major;
}
