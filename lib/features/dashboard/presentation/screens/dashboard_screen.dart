import 'package:flutter/material.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    print('Dashboard: _loadCurrentUser called');
    
    try {
      // Get the logged-in user data from secure storage
      final userData = await SecureStorageService.getUserData();
      print('Dashboard: Retrieved userData from storage: $userData');
      
      if (userData != null && userData['username'] != null) {
        print('Dashboard: Found username in storage: ${userData['username']}');
        // Load the actual logged-in user
        final user = await _userService.getUserByUsername(userData['username']);
        if (user != null) {
          print('Dashboard: Successfully loaded user from service: ${user.username} with role: ${user.role}');
          setState(() {
            _currentUser = user;
          });
        } else {
          print('Dashboard: User not found in service, using fallback staff user');
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
      } else {
        // Fallback to a default user if no user data found
        print('Dashboard: No user data found in storage, using fallback staff user');
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
    } catch (e) {
      print('Dashboard: Error loading user: $e');
      // Fallback to a default user
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
  }

  Future<void> _logout() async {
    await SecureStorageService.clearAll();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Hotel POS - Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildDashboardBody(),
    );
  }

  Widget _buildDashboardBody() {
    const spacing = 16.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCardWithRoleSummary(),
          SizedBox(height: spacing),
          _buildStatisticsAndStatusRow(),
          SizedBox(height: spacing),
          _buildModulesSection(),
          SizedBox(height: spacing),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCardWithRoleSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_currentUser!.fullName}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${_currentUser!.role.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_currentUser!.role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDescription(_currentUser!.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsAndStatusRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // Side by side on larger screens
          return Row(
            children: [
              Expanded(child: _buildStatisticsSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildSystemStatusSection()),
            ],
          );
        } else {
          // Stacked on smaller screens
          return Column(
            children: [
              _buildStatisticsSection(),
              const SizedBox(height: 16),
              _buildSystemStatusSection(),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Real-time Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactSummaryItem('Total Sales', '\$2,450', Icons.attach_money),
            _buildCompactSummaryItem('Orders Today', '12', Icons.shopping_cart),
            _buildCompactSummaryItem('Active Pets', '8', Icons.pets),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactSummaryItem('Database', 'Online', Icons.storage, statusColor: Colors.green),
            _buildCompactSummaryItem('POS System', 'Active', Icons.point_of_sale, statusColor: Colors.green),
            _buildCompactSummaryItem('Backup', 'Last: 2h ago', Icons.backup, statusColor: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSummaryItem(String label, String value, IconData icon, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    if (_currentUser == null) return const SizedBox.shrink();
    
    final availableModules = _getAvailableModulesForUser(_currentUser!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Modules',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 4.0,
          children: availableModules,
        ),
      ],
    );
  }

  List<Widget> _getAvailableModulesForUser(User user) {
    final modules = <Widget>[];
    final permissionService = PermissionService();
    
    print('Dashboard: Checking modules for user: ${user.username} with role: ${user.role}');
    print('Dashboard: User permissions: ${user.permissions}');
    print('Dashboard: User isActive: ${user.isActive}');

    // POS System - Available to all active users
    if (user.isActive) {
      print('Dashboard: Adding POS System for user: ${user.username}');
      modules.add(_buildModuleCard(
        'POS System',
        'Process transactions and manage sales',
        Icons.point_of_sale,
        Colors.blue,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const POSScreen()),
        ),
      ));
    }

    // Staff Management - Manager, Owner, Admin only
    final hasStaffPermission = permissionService.hasPermission(user, SystemPermissions.manageStaff) ||
        user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Staff Management permission check: $hasStaffPermission');
    if (hasStaffPermission) {
      print('Dashboard: Adding Staff Management for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Staff Management',
        'Manage staff, schedules, and roles',
        Icons.people,
        Colors.green,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StaffManagementScreen()),
        ),
      ));
    }

    // Customer & Pet Profiles - All users can view, some can edit
    final hasCustomerPermission = permissionService.hasPermission(user, SystemPermissions.viewCustomer);
    print('Dashboard: Customer permission check: $hasCustomerPermission');
    if (hasCustomerPermission) {
      print('Dashboard: Adding Customer & Pet Profiles for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Customer & Pet Profiles',
        'Manage customer and pet information',
        Icons.pets,
        Colors.orange,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomerPetProfilesScreen()),
        ),
      ));
    }

    // Financial Operations - Manager, Owner, Admin only
    final hasFinancialPermission = permissionService.hasPermission(user, SystemPermissions.viewFinancials) ||
        user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Financial permission check: $hasFinancialPermission');
    if (hasFinancialPermission) {
      print('Dashboard: Adding Financial Operations for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Financial Operations',
        'Track accounts, transactions, and budgets',
        Icons.account_balance,
        Colors.purple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FinancialOperationsScreen()),
        ),
      ));
    }

    // Settings - Manager, Owner, Admin only
    final hasSettingsPermission = permissionService.hasPermission(user, SystemPermissions.viewSettings) ||
        user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Settings permission check: $hasSettingsPermission');
    if (hasSettingsPermission) {
      print('Dashboard: Adding Settings for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Settings',
        'Configure system preferences',
        Icons.settings,
        Colors.grey,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        ),
      ));
    }

    // Loyalty & CRM - Owner, Admin only
    final hasLoyaltyPermission = permissionService.hasPermission(user, SystemPermissions.manageLoyalty) ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Loyalty permission check: $hasLoyaltyPermission');
    if (hasLoyaltyPermission) {
      print('Dashboard: Adding Loyalty & CRM for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Loyalty & CRM',
        'Manage loyalty programs and customer relationships',
        Icons.card_giftcard,
        Colors.red,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoyaltyManagementScreen()),
        ),
      ));
    }

    // CRM Management - Owner, Admin only
    final hasCrmPermission = user.role == UserRole.owner || user.role == UserRole.administrator;
    print('Dashboard: CRM permission check: $hasCrmPermission');
    if (hasCrmPermission) {
      print('Dashboard: Adding CRM Management for user: ${user.username}');
      modules.add(_buildModuleCard(
        'CRM Management',
        'Campaigns, templates, and automated reminders',
        Icons.campaign,
        Colors.teal,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CrmManagementScreen()),
        ),
      ));
    }

    // Booking & Room Management - Staff can view, Manager+ can manage
    final hasBookingPermission = permissionService.hasPermission(user, SystemPermissions.viewBookings);
    print('Dashboard: Booking permission check: $hasBookingPermission');
    if (hasBookingPermission) {
      print('Dashboard: Adding Booking & Room Management for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Booking & Room Management',
        'Manage reservations and room availability',
        Icons.hotel,
        Colors.indigo,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingScreen()),
        ),
      ));
    }

    // Room Management - Manager, Owner, Admin only
    final hasRoomPermission = permissionService.hasPermission(user, SystemPermissions.manageRooms) ||
        user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Room permission check: $hasRoomPermission');
    if (hasRoomPermission) {
      print('Dashboard: Adding Room Management for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Room Management',
        'Manage rooms, cages, and facilities',
        Icons.room,
        Colors.deepPurple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoomManagementScreen()),
        ),
      ));
    }

    // Inventory & Purchasing - Manager, Owner, Admin only
    final hasInventoryPermission = permissionService.hasPermission(user, SystemPermissions.viewInventory) ||
        user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Inventory permission check: $hasInventoryPermission');
    if (hasInventoryPermission) {
      print('Dashboard: Adding Inventory & Purchasing for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Inventory & Purchasing',
        'Manage stock, supplies, and purchases',
        Icons.inventory,
        Colors.amber,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventoryScreen()),
        ),
      ));
    }

    // Reports & Analytics - Different levels based on role
    final hasReportsPermission = permissionService.hasPermission(user, SystemPermissions.viewBasicReports);
    print('Dashboard: Reports permission check: $hasReportsPermission');
    if (hasReportsPermission) {
      String description = 'Business insights and performance reports';
      if (permissionService.hasPermission(user, SystemPermissions.viewAnalytics)) {
        description = 'Advanced analytics and business insights';
      }
      
      print('Dashboard: Adding Reports & Analytics for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Reports & Analytics',
        description,
        Icons.analytics,
        Colors.cyan,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsScreen()),
        ),
      ));
    }

    // Payment Processing - Manager, Owner, Admin only
    final hasPaymentPermission = user.role == UserRole.manager ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Payment permission check: $hasPaymentPermission');
    if (hasPaymentPermission) {
      print('Dashboard: Adding Payment Processing for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Payment Processing',
        'Handle payments and invoicing',
        Icons.payment,
        Colors.lightGreen,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentsScreen()),
        ),
      ));
    }

    // Services Management - Owner, Admin only
    final hasServicesPermission = permissionService.hasPermission(user, SystemPermissions.manageServices) ||
        user.role == UserRole.owner ||
        user.role == UserRole.administrator;
    
    print('Dashboard: Services permission check: $hasServicesPermission');
    if (hasServicesPermission) {
      print('Dashboard: Adding Services Management for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Services Management',
        'Manage pet care services and packages',
        Icons.spa,
        Colors.pink,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ServicesScreen()),
        ),
      ));
    }

    print('Dashboard: Total modules available for user ${user.username}: ${modules.length}');
    return modules;
  }

  Widget _buildModuleCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced from 16 to 12
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20, // Reduced from 24 to 20
                ),
              ),
              const SizedBox(width: 10), // Reduced from 12 to 10
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13, // Reduced from 14 to 13
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10, // Reduced from 11 to 10
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2024 Cat Hotel POS System',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return Colors.red;
      case UserRole.owner:
        return Colors.purple;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.staff:
        return Colors.green;
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return 'System Administrator';
      case UserRole.owner:
        return 'Business Owner';
      case UserRole.manager:
        return 'General Manager';
      case UserRole.staff:
        return 'Staff Member';
    }
  }
}
