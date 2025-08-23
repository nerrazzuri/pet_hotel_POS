import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_configuration.freezed.dart';
part 'tax_configuration.g.dart';

enum TaxType {
  sst,
  gst,
  vat,
  salesTax,
  serviceTax,
  custom,
}

enum TaxCalculationMethod {
  inclusive,
  exclusive,
  compound,
}

@freezed
class TaxRate with _$TaxRate {
  const factory TaxRate({
    required String id,
    required String name,
    required TaxType type,
    required double rate,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? code,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    double? minimumAmount,
    double? maximumAmount,
    List<String>? applicableCategories,
    List<String>? excludedCategories,
    bool? isCompound,
    double? compoundRate,
    String? notes,
  }) = _TaxRate;

  factory TaxRate.fromJson(Map<String, dynamic> json) =>
      _$TaxRateFromJson(json);
}

@freezed
class TaxConfiguration with _$TaxConfiguration {
  const factory TaxConfiguration({
    required String id,
    required String businessId,
    required TaxCalculationMethod calculationMethod,
    required bool isTaxInclusive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? businessName,
    String? businessTaxId,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? businessWebsite,
    String? currency,
    double? exchangeRate,
    List<TaxRate>? taxRates,
    bool? autoCalculateTax,
    bool? roundTaxAmounts,
    int? taxDecimalPlaces,
    String? taxRoundingMethod,
    bool? showTaxBreakdown,
    bool? requireTaxId,
    String? defaultTaxRate,
    Map<String, dynamic>? customSettings,
    String? notes,
  }) = _TaxConfiguration;

  factory TaxConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TaxConfigurationFromJson(json);
}
