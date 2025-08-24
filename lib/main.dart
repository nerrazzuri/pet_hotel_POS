import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:cat_hotel_pos/core/services/database_service.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';
// import 'package:cat_hotel_pos/core/services/notification_service.dart';
import 'package:cat_hotel_pos/core/app_config.dart';
import 'package:cat_hotel_pos/features/auth/presentation/screens/login_screen.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';
import 'package:cat_hotel_pos/features/services/domain/services/services_data_seeder.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_data_seeder.dart';
import 'package:flutter/foundation.dart';
import 'package:cat_hotel_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cat_hotel_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:cat_hotel_pos/features/staff/presentation/screens/staff_management_screen.dart';
import 'package:cat_hotel_pos/features/settings/presentation/screens/settings_screen.dart';
import 'package:cat_hotel_pos/features/financials/presentation/screens/financial_operations_screen.dart';
import 'package:cat_hotel_pos/features/customers/presentation/screens/customer_pet_profiles_screen.dart';
import 'package:cat_hotel_pos/features/loyalty/presentation/screens/loyalty_management_screen.dart';
import 'package:cat_hotel_pos/features/crm/presentation/screens/crm_management_screen.dart';
import 'package:cat_hotel_pos/features/booking/presentation/screens/booking_screen.dart';
import 'package:cat_hotel_pos/features/booking/presentation/screens/room_management_screen.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:cat_hotel_pos/features/reports/presentation/screens/reports_screen.dart';
import 'package:cat_hotel_pos/features/payments/presentation/screens/payments_screen.dart';
import 'package:cat_hotel_pos/features/services/presentation/screens/services_screen.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/screens/setup_wizard_screen.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_demo.dart';

// Import window manager for custom window frame
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';
import 'package:cat_hotel_pos/core/widgets/global_app_wrapper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop platforms
  if (!kIsWeb) {
    try {
      await windowManager.ensureInitialized();
      
      // Configure basic window properties
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1200, 800),
        center: true,
        minimumSize: Size(800, 600),
        titleBarStyle: TitleBarStyle.hidden, // Hide default title bar
      );
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      
      print('Window manager initialized successfully');
    } catch (e) {
      print('Error initializing window manager: $e');
    }
  }
  
  print('main() called');
  print('kIsWeb: $kIsWeb');
  
  // Initialize services
  if (kIsWeb) {
    print('Web platform detected, initializing web storage...');
    try {
      await WebStorageService.initialize();
      print('WebStorageService.initialize() completed successfully');
      
      print('Testing web storage...');
      WebStorageService.testWebStorage();
      print('Web storage test completed');
      
      print('Seeding default data...');
      WebStorageService.seedDefaultData();
      print('Default data seeding completed');
      
      print('Seeding Services & Products data...');
      await ServicesDataSeeder.seedAllData();
      print('Services & Products data seeding completed');
      
      print('Seeding Customer & Pet data...');
      await CustomerDataSeeder.seedAllData();
      print('Customer & Pet data seeding completed');
      
      print('Web storage initialized and seeded');
    } catch (e) {
      print('Error initializing web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  } else {
    print('Desktop platform detected, initializing database...');
    print('DatabaseService initialized');
    
    try {
      print('Sample data seeded successfully');
      
      print('Seeding Services & Products data for desktop...');
      await ServicesDataSeeder.seedAllData();
      print('Services & Products data seeding completed for desktop');
      
      print('Seeding Customer & Pet data for desktop...');
      await CustomerDataSeeder.seedAllData();
      print('Customer & Pet data seeding completed for desktop');
    } catch (e) {
      print('Error seeding sample data: $e');
    }
  }
  
  // Initialize secure storage service
  try {
    await SecureStorageService.initialize();
    print('SecureStorageService initialized');
  } catch (e) {
    print('Error initializing secure storage: $e');
  }
  
  await AppConfig.initialize();
  print('AppConfig initialized');
  
  print('All services initialized, running app...');
  runApp(const ProviderScope(child: CatHotelPOSApp()));
}

class CatHotelPOSApp extends StatelessWidget {
  const CatHotelPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Cat Hotel POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: GlobalAppHelpers.wrapLoginScreen(const LoginScreen()),
      routes: {
        '/dashboard': (context) => GlobalAppHelpers.wrapDashboardScreen(const DashboardScreen()),
        '/pos': (context) => GlobalAppHelpers.wrapPOSScreen(const POSScreen()),
        '/staff': (context) => GlobalAppHelpers.wrapScreen(
          child: const StaffManagementScreen(),
          title: 'Staff Management',
          titleBarColor: Colors.indigo[700],
        ),
        '/settings': (context) => GlobalAppHelpers.wrapSettingsScreen(const SettingsScreen()),
        '/financials': (context) => GlobalAppHelpers.wrapFinancialScreen(const FinancialOperationsScreen()),
        '/customers': (context) => GlobalAppHelpers.wrapCustomerScreen(const CustomerPetProfilesScreen()),
        '/loyalty': (context) => GlobalAppHelpers.wrapScreen(
          child: const LoyaltyManagementScreen(),
          title: 'Loyalty Program',
          titleBarColor: Colors.pink[700],
        ),
        '/crm': (context) => GlobalAppHelpers.wrapScreen(
          child: const CrmManagementScreen(),
          title: 'CRM Management',
          titleBarColor: Colors.green[700],
        ),
        '/booking': (context) => GlobalAppHelpers.wrapBookingScreen(const BookingScreen()),
        '/rooms': (context) => GlobalAppHelpers.wrapScreen(
          child: const RoomManagementScreen(),
          title: 'Room Management',
          titleBarColor: Colors.red[700],
        ),
        '/inventory': (context) => GlobalAppHelpers.wrapInventoryScreen(const InventoryScreen()),
        '/reports': (context) => GlobalAppHelpers.wrapReportsScreen(const ReportsScreen()),
        '/payments': (context) => GlobalAppHelpers.wrapScreen(
          child: const PaymentsScreen(),
          title: 'Payment Processing',
          titleBarColor: Colors.blue[700],
        ),
        '/services': (context) => GlobalAppHelpers.wrapServicesScreen(const ServicesScreen()),
        '/setup-wizard': (context) => GlobalAppHelpers.wrapScreen(
          child: const SetupWizardScreen(),
          title: 'Setup Wizard',
          titleBarColor: Colors.grey[700],
        ),
        '/custom-window-demo': (context) => GlobalAppHelpers.wrapScreen(
          child: const CustomWindowDemo(),
          title: 'Custom Window Demo',
          titleBarColor: Colors.purple[700],
        ),
      },
    );

    // For desktop platforms, return the app directly
    // Custom window frame will be implemented differently
    return app;
  }
}
