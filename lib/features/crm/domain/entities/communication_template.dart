import 'package:freezed_annotation/freezed_annotation.dart';

part 'communication_template.freezed.dart';
part 'communication_template.g.dart';

enum TemplateType {
  email,
  sms,
  whatsapp,
  push,
}

enum TemplateCategory {
  booking,
  vaccination,
  loyalty,
  marketing,
  reminder,
  notification,
}

@freezed
class CommunicationTemplate with _$CommunicationTemplate {
  const factory CommunicationTemplate({
    required String id,
    required String name,
    required String description,
    required TemplateType type,
    required TemplateCategory category,
    required String subject,
    required String content,
    required Map<String, String> variables,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
  }) = _CommunicationTemplate;

  factory CommunicationTemplate.fromJson(Map<String, dynamic> json) =>
      _$CommunicationTemplateFromJson(json);
}
