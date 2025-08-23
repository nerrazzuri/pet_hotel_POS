import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cat_hotel_pos/core/theme/app_theme.dart';
import 'package:cat_hotel_pos/features/auth/presentation/screens/login_screen.dart';
import 'package:cat_hotel_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cat_hotel_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:cat_hotel_pos/features/booking/presentation/screens/booking_screen.dart';
import 'package:cat_hotel_pos/features/customers/presentation/screens/customers_screen.dart';
import 'package:cat_hotel_pos/features/services/presentation/screens/services_screen.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:cat_hotel_pos/features/reports/presentation/screens/reports_screen.dart';
import 'package:cat_hotel_pos/features/settings/presentation/screens/settings_screen.dart';

class CatHotelPOSApp extends ConsumerWidget {
  const CatHotelPOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const POSScreen(),
        ),
        GoRoute(
          path: '/booking',
          builder: (context, state) => const BookingScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersScreen(),
        ),
                          GoRoute(
                    path: '/services',
                    builder: (context, state) => const ServicesScreen(),
                  ),
                  GoRoute(
                    path: '/inventory',
                    builder: (context, state) => const InventoryScreen(),
                  ),
                  GoRoute(
                    path: '/reports',
                    builder: (context, state) => const ReportsScreen(),
                  ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorScreen(),
    );

    return MaterialApp.router(
      title: 'Cat Hotel POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
