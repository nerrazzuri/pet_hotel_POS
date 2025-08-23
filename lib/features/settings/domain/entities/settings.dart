import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    required String id,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
    required String currency,
    required String timezone,
    required String language,
    required bool enableNotifications,
    required bool enableBiometricAuth,
    required bool enableAutoBackup,
    required String backupFrequency,
    required bool enableTaxCalculation,
    required double defaultTaxRate,
    required bool enableReceiptPrinting,
    required String receiptHeader,
    required String receiptFooter,
    required bool enableEmailReceipts,
    required bool enableWhatsAppReceipts,
    required String smtpServer,
    required int smtpPort,
    required String smtpUsername,
    required String smtpPassword,
    required bool enableSsl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  factory Settings.create({
    required String businessName,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
    String? currency,
    String? timezone,
    String? language,
    bool? enableNotifications,
    bool? enableBiometricAuth,
    bool? enableAutoBackup,
    String? backupFrequency,
    bool? enableTaxCalculation,
    double? defaultTaxRate,
    bool? enableReceiptPrinting,
    String? receiptHeader,
    String? receiptFooter,
    bool? enableEmailReceipts,
    bool? enableWhatsAppReceipts,
    String? smtpServer,
    int? smtpPort,
    String? smtpUsername,
    String? smtpPassword,
    bool? enableSsl,
  }) {
    return Settings(
      id: 'settings_001',
      businessName: businessName,
      businessAddress: businessAddress,
      businessPhone: businessPhone,
      businessEmail: businessEmail,
      currency: currency ?? 'MYR',
      timezone: timezone ?? 'Asia/Kuala_Lumpur',
      language: language ?? 'en',
      enableNotifications: enableNotifications ?? true,
      enableBiometricAuth: enableBiometricAuth ?? false,
      enableAutoBackup: enableAutoBackup ?? true,
      backupFrequency: backupFrequency ?? 'daily',
      enableTaxCalculation: enableTaxCalculation ?? true,
      defaultTaxRate: defaultTaxRate ?? 6.0,
      enableReceiptPrinting: enableReceiptPrinting ?? true,
      receiptHeader: receiptHeader ?? 'Cat Hotel & Pet Services',
      receiptFooter: receiptFooter ?? 'Thank you for your business!',
      enableEmailReceipts: enableEmailReceipts ?? true,
      enableWhatsAppReceipts: enableWhatsAppReceipts ?? false,
      smtpServer: smtpServer ?? 'smtp.gmail.com',
      smtpPort: smtpPort ?? 587,
      smtpUsername: smtpUsername ?? '',
      smtpPassword: smtpPassword ?? '',
      enableSsl: enableSsl ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum BackupFrequency {
  @JsonValue('hourly')
  hourly,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

enum Language {
  @JsonValue('en')
  english,
  @JsonValue('ms')
  malay,
  @JsonValue('zh')
  chinese,
  @JsonValue('ta')
  tamil,
}

extension BackupFrequencyExtension on BackupFrequency {
  String get displayName {
    switch (this) {
      case BackupFrequency.hourly:
        return 'Hourly';
      case BackupFrequency.daily:
        return 'Daily';
      case BackupFrequency.weekly:
        return 'Weekly';
      case BackupFrequency.monthly:
        return 'Monthly';
    }
  }
}

extension LanguageExtension on Language {
  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.malay:
        return 'Bahasa Melayu';
      case Language.chinese:
        return '中文';
      case Language.tamil:
        return 'தமிழ்';
    }
  }
}
