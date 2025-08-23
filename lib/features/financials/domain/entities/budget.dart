import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String name,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    required String currency,
    required BudgetStatus status,
    String? description,
    List<BudgetCategory>? categories,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  factory Budget.create({
    required String name,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    String? description,
    List<BudgetCategory>? categories,
  }) {
    return Budget(
      id: 'BUD_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      period: period,
      startDate: startDate,
      endDate: endDate,
      totalAmount: totalAmount,
      currency: 'MYR',
      status: BudgetStatus.active,
      description: description,
      categories: categories ?? [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@freezed
class BudgetCategory with _$BudgetCategory {
  const factory BudgetCategory({
    required String id,
    required String name,
    required double allocatedAmount,
    required double spentAmount,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetCategory;

  factory BudgetCategory.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryFromJson(json);

  factory BudgetCategory.create({
    required String name,
    required double allocatedAmount,
    String? description,
  }) {
    return BudgetCategory(
      id: 'CAT_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      allocatedAmount: allocatedAmount,
      spentAmount: 0.0,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

enum BudgetPeriod {
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('custom')
  custom,
}

enum BudgetStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }
}

extension BudgetStatusExtension on BudgetStatus {
  String get displayName {
    switch (this) {
      case BudgetStatus.draft:
        return 'Draft';
      case BudgetStatus.active:
        return 'Active';
      case BudgetStatus.completed:
        return 'Completed';
      case BudgetStatus.cancelled:
        return 'Cancelled';
    }
  }
}
