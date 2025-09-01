import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/time_tracking_service.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';
import 'package:cat_hotel_pos/features/dashboard/presentation/widgets/staff_hr_module.dart';
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
  late final TimeTrackingService _timeTrackingService;
  late final StaffDao _staffDao;
  User? _currentUser;
  StaffMember? _currentStaff;
  TimeTracking? _activeTracking;
  bool _isTimeTrackingLoading = false;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _initializeServices() {
    _permissionService = PermissionService();
    _auditService = AuditService();
    _userService = UserService(_permissionService, _auditService);
    _authService = AuthService(_userService, _auditService);
    _secureStorage = SecureStorageService();
    _timeTrackingService = TimeTrackingService(TimeTrackingDao());
    _staffDao = StaffDao();
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
          // Load staff data for time tracking if user is staff-level
          if (_isStaffLevelUser(user)) {
            await _loadCurrentStaff();
          }
        } else {
          print('Dashboard: User not found in service, using fallback staff user');
          final fallbackUser = User(
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
          setState(() {
            _currentUser = fallbackUser;
          });
          // Load staff data for time tracking
          await _loadCurrentStaff();
        }
      } else {
        // Fallback to a default user if no user data found
        print('Dashboard: No user data found in storage, using fallback staff user');
        final fallbackUser = User(
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
        setState(() {
          _currentUser = fallbackUser;
        });
        // Load staff data for time tracking
        await _loadCurrentStaff();
      }
    } catch (e) {
      print('Dashboard: Error loading user: $e');
      // Fallback to a default user
      final fallbackUser = User(
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
      setState(() {
        _currentUser = fallbackUser;
      });
      // Load staff data for time tracking
      await _loadCurrentStaff();
    }
  }

  Future<void> _loadCurrentStaff() async {
    try {
      final staffMembers = await _staffDao.getAll();
      // For demo purposes, select the first staff member
      // In a real app, this would be the logged-in user
      if (staffMembers.isNotEmpty) {
        _currentStaff = staffMembers.first;
        await _loadActiveTracking();
      }
    } catch (e) {
      print('Error loading staff: $e');
    }
  }

  Future<void> _loadActiveTracking() async {
    if (_currentStaff == null) return;
    
    try {
      _activeTracking = await _timeTrackingService.getActiveTracking(_currentStaff!.id);
      if (mounted) {
        setState(() {});
        _startOrStopDurationTimer();
      }
    } catch (e) {
      print('Error loading active tracking: $e');
    }
  }

  void _startOrStopDurationTimer() {
    _durationTimer?.cancel();
    if (_activeTracking != null) {
      // Start timer to update duration every second
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
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
      body: Column(
        children: [
          // Custom Title Bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title (Draggable)
                Expanded(
                  child: GestureDetector(
                    onPanStart: (details) {
                      if (!kIsWeb) {
                        windowManager.startDragging();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cat Hotel POS - Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Window Controls
                Row(
                  children: [
                    // Logout Button
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                      tooltip: 'Logout',
                    ),
                    // Minimize Button
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () async {
                        if (!kIsWeb) {
                          await windowManager.minimize();
                        }
                      },
                      tooltip: 'Minimize',
                    ),
                    // Maximize Button
                    IconButton(
                      icon: const Icon(Icons.crop_free, color: Colors.white),
                      onPressed: () async {
                        if (!kIsWeb) {
                          await windowManager.maximize();
                        }
                      },
                      tooltip: 'Maximize',
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        if (!kIsWeb) {
                          await windowManager.close();
                        }
                      },
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dashboard Content
          Expanded(child: _buildDashboardBody()),
        ],
      ),
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
          // Add HR module for staff-level users
          if (_currentUser != null && _isStaffLevelUser(_currentUser!)) ...[
            const StaffHRModule(),
            SizedBox(height: spacing),
          ],
          _buildModulesSection(),
          SizedBox(height: spacing),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCardWithRoleSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.indigo[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[700]!.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${_currentUser!.fullName}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to manage your cat hotel operations?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getRoleDescription(_currentUser!.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getGreetingEmoji(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Time tracking widget for staff-level users
                if (_currentUser != null && _isStaffLevelUser(_currentUser!))
                  _buildTimeTrackingCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsAndStatusRow() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Real-time Statistics & System Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Single row with all statistics
            Row(
              children: [
                Expanded(
                  child: _buildCompactSummaryItem('Total Sales', '\$2,450', Icons.attach_money, statusColor: Colors.green),
                ),
                Expanded(
                  child: _buildCompactSummaryItem('Orders Today', '12', Icons.shopping_cart, statusColor: Colors.orange),
                ),
                Expanded(
                  child: _buildCompactSummaryItem('Active Pets', '8', Icons.pets, statusColor: Colors.purple),
                ),
                Expanded(
                  child: _buildCompactSummaryItem('Database', 'Online', Icons.storage, statusColor: Colors.blue),
                ),
                Expanded(
                  child: _buildCompactSummaryItem('POS System', 'Active', Icons.point_of_sale, statusColor: Colors.green),
                ),
                Expanded(
                  child: _buildCompactSummaryItem('Backup', '2h ago', Icons.backup, statusColor: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }




    

  Widget _buildCompactSummaryItem(String label, String value, IconData icon, {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: statusColor ?? Colors.blue[600]),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor ?? Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    if (_currentUser == null) return const SizedBox.shrink();
    
    final availableModules = _getAvailableModulesForUser(_currentUser!);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apps,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Available Modules',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${availableModules.length} modules',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 3.5,
            children: availableModules,
          ),
        ],
      ),
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
        () => Navigator.pushNamed(context, '/pos'),
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
        () => Navigator.pushNamed(context, '/staff'),
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
        () => Navigator.pushNamed(context, '/customers'),
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
        () => Navigator.pushNamed(context, '/financials'),
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
        () => Navigator.pushNamed(context, '/settings'),
      ));
    }

    // Setup Wizard - Owner, Admin only
    final hasSetupWizardPermission = user.role == UserRole.owner || user.role == UserRole.administrator;
    print('Dashboard: Setup Wizard permission check: $hasSetupWizardPermission');
    if (hasSetupWizardPermission) {
      print('Dashboard: Adding Setup Wizard for user: ${user.username}');
      modules.add(_buildModuleCard(
        'Setup Wizard',
        'Configure system features and permissions',
        Icons.admin_panel_settings,
        Colors.deepOrange,
        () => Navigator.pushNamed(context, '/setup-wizard'),
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
        () => Navigator.pushNamed(context, '/loyalty'),
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
        () => Navigator.pushNamed(context, '/crm'),
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
        () => Navigator.pushNamed(context, '/booking'),
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
        () => Navigator.pushNamed(context, '/rooms'),
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
        () => Navigator.pushNamed(context, '/inventory'),
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
        () => Navigator.pushNamed(context, '/reports'),
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
        () => Navigator.pushNamed(context, '/payments'),
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
        () => Navigator.pushNamed(context, '/services'),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pets,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '© 2024 Cat Hotel POS System',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    Text(
                      'System Online',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅';
    } else if (hour < 17) {
      return '🌞';
    } else {
      return '🌙';
    }
  }

  Widget _buildTimeTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Time Tracking',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            height: 60,
            child: ElevatedButton(
              onPressed: _isTimeTrackingLoading ? null : _toggleTimeTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTimeTrackingButtonColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: _isTimeTrackingLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _getTimeTrackingIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getTimeTrackingLabel(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_activeTracking != null) ...[
            const SizedBox(height: 4),
            Text(
              _getDuration(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTimeTrackingButtonColor() {
    if (_activeTracking == null) {
      return Colors.green; // Clock In
    } else {
      return Colors.red; // Clock Out
    }
  }

  IconData _getTimeTrackingIcon() {
    if (_activeTracking == null) {
      return Icons.login; // Clock In
    } else {
      return Icons.logout; // Clock Out
    }
  }

  String _getTimeTrackingLabel() {
    if (_activeTracking == null) {
      return 'Clock In';
    } else {
      return 'Clock Out';
    }
  }

  String _getDuration() {
    if (_activeTracking == null) return '';
    
    final duration = DateTime.now().difference(_activeTracking!.clockInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleTimeTracking() async {
    if (_currentStaff == null) return;

    setState(() => _isTimeTrackingLoading = true);
    try {
      if (_activeTracking == null) {
        // Clock In
        await _timeTrackingService.clockIn(
          staffMemberId: _currentStaff!.id,
          location: 'Main Office',
        );
        _showSuccessSnackBar('Clocked in successfully');
      } else {
        // Clock Out
        await _timeTrackingService.clockOut(staffMemberId: _currentStaff!.id);
        _showSuccessSnackBar('Clocked out successfully');
      }
      await _loadActiveTracking();
      _startOrStopDurationTimer();
    } catch (e) {
      _showErrorSnackBar('Failed to ${_activeTracking == null ? 'clock in' : 'clock out'}: $e');
    } finally {
      setState(() => _isTimeTrackingLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  bool _isStaffLevelUser(User user) {
    return user.role == UserRole.staff || user.role == UserRole.manager;
  }
}