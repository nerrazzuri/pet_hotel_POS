import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';

/// Global wrapper that automatically adds custom title bar to every screen
/// This ensures consistent window controls across the entire application
class GlobalAppWrapper extends StatelessWidget {
  final Widget child;
  final String? screenTitle;
  final Color? titleBarColor;
  final bool showMinimize;
  final bool showMaximize;
  final bool showClose;

  const GlobalAppWrapper({
    super.key,
    required this.child,
    this.screenTitle,
    this.titleBarColor,
    this.showMinimize = true,
    this.showMaximize = true,
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current route name for the title
    String title = screenTitle ?? _getScreenTitle(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar for every screen
          CustomTitleBar(
            title: 'Cat Hotel POS - $title',
            backgroundColor: titleBarColor ?? _getDefaultColor(title),
            onMinimize: showMinimize ? () async => await windowManager.minimize() : null,
            onMaximize: showMaximize ? () async => await windowManager.maximize() : null,
            onClose: showClose ? () async => await windowManager.close() : null,
          ),
          
          // Screen content
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Get screen title from context or route
  String _getScreenTitle(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null) {
      final settings = route.settings;
      if (settings.name != null) {
        return _formatRouteName(settings.name!);
      }
    }
    return 'Application';
  }

  /// Format route name to readable title
  String _formatRouteName(String routeName) {
    if (routeName.startsWith('/')) {
      routeName = routeName.substring(1);
    }
    
    // Convert route names to readable titles
    switch (routeName) {
      case 'dashboard':
        return 'Dashboard';
      case 'pos':
        return 'Point of Sale';
      case 'staff':
        return 'Staff Management';
      case 'settings':
        return 'Settings';
      case 'financials':
        return 'Financial Operations';
      case 'customers':
        return 'Customer Management';
      case 'loyalty':
        return 'Loyalty Program';
      case 'crm':
        return 'CRM Management';
      case 'booking':
        return 'Booking System';
      case 'rooms':
        return 'Room Management';
      case 'inventory':
        return 'Inventory Management';
      case 'reports':
        return 'Reports & Analytics';
      case 'payments':
        return 'Payment Processing';
      case 'services':
        return 'Services & Products';
      case 'setup-wizard':
        return 'Setup Wizard';
      default:
        // Convert kebab-case to Title Case
        return routeName.split('-').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
  }

  /// Get default color for different screen types
  Color _getDefaultColor(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('pos') || lowerTitle.contains('sale')) {
      return Colors.blue[700]!;
    } else if (lowerTitle.contains('inventory') || lowerTitle.contains('stock')) {
      return Colors.orange[700]!;
    } else if (lowerTitle.contains('customer') || lowerTitle.contains('crm')) {
      return Colors.green[700]!;
    } else if (lowerTitle.contains('report') || lowerTitle.contains('analytics')) {
      return Colors.purple[700]!;
    } else if (lowerTitle.contains('setting') || lowerTitle.contains('config')) {
      return Colors.grey[700]!;
    } else if (lowerTitle.contains('financial') || lowerTitle.contains('account')) {
      return Colors.teal[700]!;
    } else if (lowerTitle.contains('booking') || lowerTitle.contains('reservation')) {
      return Colors.red[700]!;
    } else if (lowerTitle.contains('staff') || lowerTitle.contains('employee')) {
      return Colors.indigo[700]!;
    } else if (lowerTitle.contains('loyalty') || lowerTitle.contains('reward')) {
      return Colors.pink[700]!;
    } else if (lowerTitle.contains('service') || lowerTitle.contains('product')) {
      return Colors.amber[700]!;
    } else {
      return Colors.indigo[700]!;
    }
  }
}

/// Helper class for quick integration
class GlobalAppHelpers {
  /// Wrap any screen with custom title bar
  static Widget wrapScreen({
    required Widget child,
    String? title,
    Color? titleBarColor,
    bool showMinimize = true,
    bool showMaximize = true,
    bool showClose = true,
  }) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: title,
      titleBarColor: titleBarColor,
      showMinimize: showMinimize,
      showMaximize: showMaximize,
      showClose: showClose,
    );
  }

  /// Wrap login screen (no minimize/maximize)
  static Widget wrapLoginScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Login',
      titleBarColor: Colors.teal[700],
      showMinimize: false,
      showMaximize: false,
      showClose: true,
    );
  }

  /// Wrap dashboard screen
  static Widget wrapDashboardScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Dashboard',
      titleBarColor: Colors.teal[700],
    );
  }

  /// Wrap POS screen
  static Widget wrapPOSScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Point of Sale',
      titleBarColor: Colors.blue[700],
    );
  }

  /// Wrap customer management screen
  static Widget wrapCustomerScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Customer Management',
      titleBarColor: Colors.green[700],
    );
  }

  /// Wrap inventory screen
  static Widget wrapInventoryScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Inventory Management',
      titleBarColor: Colors.orange[700],
    );
  }

  /// Wrap financial screen
  static Widget wrapFinancialScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Financial Operations',
      titleBarColor: Colors.teal[700],
    );
  }

  /// Wrap reports screen
  static Widget wrapReportsScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Reports & Analytics',
      titleBarColor: Colors.purple[700],
    );
  }

  /// Wrap settings screen
  static Widget wrapSettingsScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Settings',
      titleBarColor: Colors.grey[700],
    );
  }

  /// Wrap booking screen
  static Widget wrapBookingScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Booking System',
      titleBarColor: Colors.red[700],
    );
  }

  /// Wrap services screen
  static Widget wrapServicesScreen(Widget child) {
    return GlobalAppWrapper(
      child: child,
      screenTitle: 'Services & Products',
      titleBarColor: Colors.amber[700],
    );
  }
}
