import 'package:freezed_annotation/freezed_annotation.dart';

part 'incident_note.freezed.dart';
part 'incident_note.g.dart';

@JsonEnum()
enum IncidentSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@JsonEnum()
enum IncidentType {
  @JsonValue('medical')
  medical,
  @JsonValue('behavioral')
  behavioral,
  @JsonValue('injury')
  injury,
  @JsonValue('illness')
  illness,
  @JsonValue('allergic_reaction')
  allergicReaction,
  @JsonValue('escape_attempt')
  escapeAttempt,
  @JsonValue('aggression')
  aggression,
  @JsonValue('other')
  other,
}

@JsonEnum()
enum IncidentStatus {
  @JsonValue('open')
  open,
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
class IncidentNote with _$IncidentNote {
  const factory IncidentNote({
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
    required DateTime incidentDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? reportedBy,
    String? assignedTo,
    String? location,
    String? weatherConditions,
    List<String>? witnesses,
    List<String>? involvedPets,
    String? immediateAction,
    String? followUpAction,
    DateTime? resolvedAt,
    String? resolutionNotes,
    List<String>? photoUrls,
    List<String>? videoUrls,
    Map<String, dynamic>? medicalData,
    bool? requiresVetAttention,
    bool? requiresCustomerNotification,
    String? customerNotificationSent,
    Map<String, dynamic>? metadata,
  }) = _IncidentNote;

  factory IncidentNote.fromJson(Map<String, dynamic> json) => _$IncidentNoteFromJson(json);
}

extension IncidentNoteExtension on IncidentNote {
  bool get isOpen => status == IncidentStatus.open || status == IncidentStatus.investigating;
  bool get isResolved => status == IncidentStatus.resolved || status == IncidentStatus.closed;
  bool get isCritical => severity == IncidentSeverity.critical;
  bool get needsImmediateAttention => isCritical && isOpen;
  
  int get daysSinceIncident {
    final now = DateTime.now();
    return now.difference(incidentDate).inDays;
  }
  
  bool get isOverdue {
    if (status == IncidentStatus.open || status == IncidentStatus.investigating) {
      return daysSinceIncident > 7;
    }
    return false;
  }
}
