import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/auth_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/user_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/permission_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/permission.dart';
import 'package:cat_hotel_pos/features/auth/presentation/screens/login_screen.dart';
import 'package:cat_hotel_pos/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:cat_hotel_pos/features/settings/presentation/screens/settings_screen.dart';
import 'package:cat_hotel_pos/features/financials/presentation/screens/financial_operations_screen.dart';
import 'package:cat_hotel_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:cat_hotel_pos/features/customers/presentation/screens/customer_pet_profiles_screen.dart';
import 'package:cat_hotel_pos/features/loyalty/presentation/screens/loyalty_management_screen.dart';
import 'package:cat_hotel_pos/features/crm/presentation/screens/crm_management_screen.dart';
import 'package:cat_hotel_pos/features/booking/presentation/screens/booking_screen.dart';
import 'package:cat_hotel_pos/features/booking/presentation/screens/room_management_screen.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:cat_hotel_pos/features/reports/presentation/screens/reports_screen.dart';
import 'package:cat_hotel_pos/features/payments/presentation/screens/payments_screen.dart';
import 'package:cat_hotel_pos/features/services/presentation/screens/services_screen.dart';

/// Dashboard Screen with Custom Window Frame Integration
/// This shows how to add a custom title bar to your existing dashboard
class DashboardWithCustomFrame extends StatefulWidget {
  const DashboardWithCustomFrame({super.key});

  @override
  State<DashboardWithCustomFrame> createState() => _DashboardWithCustomFrameState();
}

class _DashboardWithCustomFrameState extends State<DashboardWithCustomFrame> {
  late final AuthService _authService;
  late final SecureStorageService _secureStorage;
  late final UserService _userService;
  late final AuditService _auditService;
  late final PermissionService _permissionService;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCurrentUser();
  }

  void _initializeServices() {
    _permissionService = PermissionService();
    _auditService = AuditService();
    _userService = UserService(_permissionService, _auditService);
    _authService = AuthService(_userService, _auditService);
    _secureStorage = SecureStorageService();
  }

  Future<void> _loadCurrentUser() async {
    // ... existing user loading logic
    setState(() {
      _currentUser = User(
        id: 'staff',
        username: 'staff',
        email: 'staff@cathotel.com',
        fullName: 'Staff Member',
        role: UserRole.staff,
        permissions: {},
        isActive: true,
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar with Window Controls
          CustomTitleBar(
            title: 'Cat Hotel POS System - Dashboard',
            backgroundColor: Colors.teal[700],
            onMinimize: () async => await windowManager.minimize(),
            onMaximize: () async => await windowManager.maximize(),
            onClose: () async => await windowManager.close(),
          ),
          
          // Main Dashboard Content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Welcome Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${_currentUser?.fullName ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your cat hotel operations efficiently',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Module Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: [
                          _buildModuleCard(
                            'POS System',
                            Icons.point_of_sale,
                            Colors.blue,
                            () => Navigator.pushNamed(context, '/pos'),
                          ),
                          _buildModuleCard(
                            'Customer Management',
                            Icons.people,
                            Colors.green,
                            () => Navigator.pushNamed(context, '/customers'),
                          ),
                          _buildModuleCard(
                            'Services & Products',
                            Icons.inventory,
                            Colors.orange,
                            () => Navigator.pushNamed(context, '/services'),
                          ),
                          _buildModuleCard(
                            'Inventory Management',
                            Icons.warehouse,
                            Colors.purple,
                            () => Navigator.pushNamed(context, '/inventory'),
                          ),
                          _buildModuleCard(
                            'Booking System',
                            Icons.calendar_today,
                            Colors.red,
                            () => Navigator.pushNamed(context, '/booking'),
                          ),
                          _buildModuleCard(
                            'Reports & Analytics',
                            Icons.analytics,
                            Colors.indigo,
                            () => Navigator.pushNamed(context, '/reports'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
