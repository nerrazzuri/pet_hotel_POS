import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

@JsonEnum()
enum PermissionCategory {
  @JsonValue('sales')
  sales,
  @JsonValue('customer')
  customer,
  @JsonValue('booking')
  booking,
  @JsonValue('inventory')
  inventory,
  @JsonValue('reports')
  reports,
  @JsonValue('staff')
  staff,
  @JsonValue('system')
  system,
  @JsonValue('financial')
  financial,
}

@freezed
class Permission with _$Permission {
  const factory Permission({
    required String id,
    required String name,
    required String description,
    required PermissionCategory category,
    required String key,
    required bool isDefaultEnabled,
    required UserRole minimumRole,
  }) = _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
}

// Predefined permissions for the system
class SystemPermissions {
  // Sales & POS
  static const salesRegister = 'sales_register';
  static const applyDiscount = 'apply_discount';
  static const voidTransaction = 'void_transaction';
  static const refundTransaction = 'refund_transaction';
  static const splitBill = 'split_bill';
  static const holdCart = 'hold_cart';
  
  // Customer Management
  static const viewCustomer = 'view_customer';
  static const addCustomer = 'add_customer';
  static const editCustomer = 'edit_customer';
  static const deleteCustomer = 'delete_customer';
  static const viewPetProfile = 'view_pet_profile';
  static const editPetProfile = 'edit_pet_profile';
  
  // Booking & Room Management
  static const viewBookings = 'view_bookings';
  static const createBooking = 'create_booking';
  static const editBooking = 'edit_booking';
  static const cancelBooking = 'cancel_booking';
  static const viewRooms = 'view_rooms';
  static const manageRooms = 'manage_rooms';
  
  // Inventory & Services
  static const viewInventory = 'view_inventory';
  static const editInventory = 'edit_inventory';
  static const manageServices = 'manage_services';
  static const manageProducts = 'manage_products';
  static const viewSuppliers = 'view_suppliers';
  static const manageSuppliers = 'manage_suppliers';
  
  // Reports & Analytics
  static const viewBasicReports = 'view_basic_reports';
  static const viewFinancialReports = 'view_financial_reports';
  static const viewAnalytics = 'view_analytics';
  static const exportReports = 'export_reports';
  
  // Staff Management
  static const viewStaff = 'view_staff';
  static const manageStaff = 'manage_staff';
  static const viewSchedules = 'view_schedules';
  static const manageSchedules = 'manage_schedules';
  
  // System Settings
  static const viewSettings = 'view_settings';
  static const manageSettings = 'manage_settings';
  static const managePermissions = 'manage_permissions';
  static const viewAuditLogs = 'view_audit_logs';
  
  // Financial Operations
  static const viewFinancials = 'view_financials';
  static const managePricing = 'manage_pricing';
  static const viewTaxReports = 'view_tax_reports';
  static const manageLoyalty = 'manage_loyalty';
}
