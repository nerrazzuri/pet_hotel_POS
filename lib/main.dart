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
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('main() called');
  print('kIsWeb: $kIsWeb');
  
  // Initialize Hive
  // await Hive.initFlutter();
  // print('Hive initialized');
  
  // Initialize services
  if (kIsWeb) {
    print('Web platform detected, initializing web storage...');
    // Initialize web storage for web platforms
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
      
      print('Web storage initialized and seeded');
    } catch (e) {
      print('Error initializing web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  } else {
    print('Desktop platform detected, initializing database...');
    // Initialize database for desktop platforms
    // await DatabaseService.initialize();
    print('DatabaseService initialized');
    
    // Seed database with sample data
    try {
      // await DatabaseService.seedSampleData();
      print('Sample data seeded successfully');
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
  
  // await NotificationService.initialize();
  // print('NotificationService initialized');
  
  await AppConfig.initialize();
  print('AppConfig initialized');
  
  print('All services initialized, running app...');
  runApp(const ProviderScope(child: CatHotelPOSApp()));
}

class CatHotelPOSApp extends StatelessWidget {
  const CatHotelPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LoginScreen(),
    );
  }
}
