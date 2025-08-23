import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_resend.freezed.dart';
part 'invoice_resend.g.dart';

@freezed
class InvoiceResend with _$InvoiceResend {
  const factory InvoiceResend({
    required String id,
    required DateTime resentAt,
    required String resentBy,
    required String method, // email, whatsapp, sms
    String? reason,
    String? notes,
  }) = _InvoiceResend;

  factory InvoiceResend.fromJson(Map<String, dynamic> json) => _$InvoiceResendFromJson(json);
}
