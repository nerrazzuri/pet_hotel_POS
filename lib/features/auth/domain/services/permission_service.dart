import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/permission.dart';


class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Default permission mappings for each role
  static const Map<UserRole, Map<String, bool>> _defaultPermissions = {
    UserRole.staff: {
      SystemPermissions.salesRegister: true,
      SystemPermissions.applyDiscount: true,
      SystemPermissions.holdCart: true,
      SystemPermissions.viewCustomer: true,
      SystemPermissions.addCustomer: true,
      SystemPermissions.editCustomer: true,
      SystemPermissions.viewPetProfile: true,
      SystemPermissions.editPetProfile: true,
      SystemPermissions.viewBookings: true,
      SystemPermissions.createBooking: true,
      SystemPermissions.viewBasicReports: true,
      SystemPermissions.viewSchedules: true,
    },
    UserRole.manager: {
      SystemPermissions.salesRegister: true,
      SystemPermissions.applyDiscount: true,
      SystemPermissions.voidTransaction: true,
      SystemPermissions.refundTransaction: true,
      SystemPermissions.splitBill: true,
      SystemPermissions.holdCart: true,
      SystemPermissions.viewCustomer: true,
      SystemPermissions.addCustomer: true,
      SystemPermissions.editCustomer: true,
      SystemPermissions.deleteCustomer: true,
      SystemPermissions.viewPetProfile: true,
      SystemPermissions.editPetProfile: true,
      SystemPermissions.viewBookings: true,
      SystemPermissions.createBooking: true,
      SystemPermissions.editBooking: true,
      SystemPermissions.cancelBooking: true,
      SystemPermissions.viewRooms: true,
      SystemPermissions.viewInventory: true,
      SystemPermissions.viewBasicReports: true,
      SystemPermissions.viewFinancialReports: true,
      SystemPermissions.viewStaff: true,
      SystemPermissions.viewSchedules: true,
      SystemPermissions.manageSchedules: true,
      SystemPermissions.viewSettings: true,
    },
    UserRole.owner: {
      SystemPermissions.salesRegister: true,
      SystemPermissions.applyDiscount: true,
      SystemPermissions.voidTransaction: true,
      SystemPermissions.refundTransaction: true,
      SystemPermissions.splitBill: true,
      SystemPermissions.holdCart: true,
      SystemPermissions.viewCustomer: true,
      SystemPermissions.addCustomer: true,
      SystemPermissions.editCustomer: true,
      SystemPermissions.deleteCustomer: true,
      SystemPermissions.viewPetProfile: true,
      SystemPermissions.editPetProfile: true,
      SystemPermissions.viewBookings: true,
      SystemPermissions.createBooking: true,
      SystemPermissions.editBooking: true,
      SystemPermissions.cancelBooking: true,
      SystemPermissions.viewRooms: true,
      SystemPermissions.manageRooms: true,
      SystemPermissions.viewInventory: true,
      SystemPermissions.editInventory: true,
      SystemPermissions.manageServices: true,
      SystemPermissions.manageProducts: true,
      SystemPermissions.viewSuppliers: true,
      SystemPermissions.manageSuppliers: true,
      SystemPermissions.viewBasicReports: true,
      SystemPermissions.viewFinancialReports: true,
      SystemPermissions.viewAnalytics: true,
      SystemPermissions.exportReports: true,
      SystemPermissions.viewStaff: true,
      SystemPermissions.manageStaff: true,
      SystemPermissions.viewSchedules: true,
      SystemPermissions.manageSchedules: true,
      SystemPermissions.viewSettings: true,
      SystemPermissions.manageSettings: true,
      SystemPermissions.managePermissions: true,
      SystemPermissions.viewAuditLogs: true,
      SystemPermissions.viewFinancials: true,
      SystemPermissions.managePricing: true,
      SystemPermissions.viewTaxReports: true,
      SystemPermissions.manageLoyalty: true,
    },
    UserRole.administrator: {
      // Administrator has all permissions
      SystemPermissions.salesRegister: true,
      SystemPermissions.applyDiscount: true,
      SystemPermissions.voidTransaction: true,
      SystemPermissions.refundTransaction: true,
      SystemPermissions.splitBill: true,
      SystemPermissions.holdCart: true,
      SystemPermissions.viewCustomer: true,
      SystemPermissions.addCustomer: true,
      SystemPermissions.editCustomer: true,
      SystemPermissions.deleteCustomer: true,
      SystemPermissions.viewPetProfile: true,
      SystemPermissions.editPetProfile: true,
      SystemPermissions.viewBookings: true,
      SystemPermissions.createBooking: true,
      SystemPermissions.editBooking: true,
      SystemPermissions.cancelBooking: true,
      SystemPermissions.viewRooms: true,
      SystemPermissions.manageRooms: true,
      SystemPermissions.viewInventory: true,
      SystemPermissions.editInventory: true,
      SystemPermissions.manageServices: true,
      SystemPermissions.manageProducts: true,
      SystemPermissions.viewSuppliers: true,
      SystemPermissions.manageSuppliers: true,
      SystemPermissions.viewBasicReports: true,
      SystemPermissions.viewFinancialReports: true,
      SystemPermissions.viewAnalytics: true,
      SystemPermissions.exportReports: true,
      SystemPermissions.viewStaff: true,
      SystemPermissions.manageStaff: true,
      SystemPermissions.viewSchedules: true,
      SystemPermissions.manageSchedules: true,
      SystemPermissions.viewSettings: true,
      SystemPermissions.manageSettings: true,
      SystemPermissions.managePermissions: true,
      SystemPermissions.viewAuditLogs: true,
      SystemPermissions.viewFinancials: true,
      SystemPermissions.managePricing: true,
      SystemPermissions.viewTaxReports: true,
      SystemPermissions.manageLoyalty: true,
    },
  };

  /// Get default permissions for a role
  Map<String, bool> getDefaultPermissions(UserRole role) {
    return Map.from(_defaultPermissions[role] ?? {});
  }

  /// Check if user has a specific permission
  bool hasPermission(User user, String permissionKey) {
    // Check custom permissions first
    if (user.customPermissions != null && 
        user.customPermissions!.containsKey(permissionKey)) {
      return user.customPermissions![permissionKey] ?? false;
    }
    
    // Check user's permission map
    if (user.permissions.containsKey(permissionKey)) {
      return user.permissions[permissionKey] ?? false;
    }
    
    // Fall back to default permissions for the role
    final defaultPerms = getDefaultPermissions(user.role);
    return defaultPerms[permissionKey] ?? false;
  }

  /// Check if user has any permission from a list
  bool hasAnyPermission(User user, List<String> permissionKeys) {
    return permissionKeys.any((key) => hasPermission(user, key));
  }

  /// Check if user has all permissions from a list
  bool hasAllPermissions(User user, List<String> permissionKeys) {
    return permissionKeys.every((key) => hasPermission(user, key));
  }

  /// Get all permissions for a user (including defaults)
  Map<String, bool> getAllUserPermissions(User user) {
    final allPermissions = <String, bool>{};
    
    // Add default permissions for the role
    allPermissions.addAll(getDefaultPermissions(user.role));
    
    // Override with user's custom permissions
    allPermissions.addAll(user.permissions);
    
    // Override with user's custom permissions from customPermissions
    if (user.customPermissions != null) {
      for (final entry in user.customPermissions!.entries) {
        if (entry.value is bool) {
          allPermissions[entry.key] = entry.value as bool;
        }
      }
    }
    
    return allPermissions;
  }

  /// Check if user can manage permissions (Owner or Admin only)
  bool canManagePermissions(User user) {
    return user.role == UserRole.owner || user.role == UserRole.administrator;
  }

  /// Check if user can manage staff (Manager, Owner, or Admin only)
  bool canManageStaff(User user) {
    return user.role == UserRole.manager || 
           user.role == UserRole.owner || 
           user.role == UserRole.administrator;
  }

  /// Check if user can view financial data (Manager, Owner, or Admin only)
  bool canViewFinancials(User user) {
    return user.role == UserRole.manager || 
           user.role == UserRole.owner || 
           user.role == UserRole.administrator;
  }

  /// Get permission category display name
  String getPermissionCategoryName(PermissionCategory category) {
    switch (category) {
      case PermissionCategory.sales:
        return 'Sales & POS';
      case PermissionCategory.customer:
        return 'Customer Management';
      case PermissionCategory.booking:
        return 'Booking & Rooms';
      case PermissionCategory.inventory:
        return 'Inventory & Services';
      case PermissionCategory.reports:
        return 'Reports & Analytics';
      case PermissionCategory.staff:
        return 'Staff Management';
      case PermissionCategory.system:
        return 'System Settings';
      case PermissionCategory.financial:
        return 'Financial Operations';
    }
  }
}
