import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_reprint.freezed.dart';
part 'receipt_reprint.g.dart';

@freezed
class ReceiptReprint with _$ReceiptReprint {
  const factory ReceiptReprint({
    required String id,
    required DateTime reprintedAt,
    required String reprintedBy,
    String? reason,
    String? notes,
  }) = _ReceiptReprint;

  factory ReceiptReprint.fromJson(Map<String, dynamic> json) => _$ReceiptReprintFromJson(json);
}
