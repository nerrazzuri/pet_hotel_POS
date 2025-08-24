import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';

/// A reusable wrapper that adds custom window frame to any existing module
/// This makes it easy to integrate custom window frames without modifying existing code
class ModuleWrapperWithCustomFrame extends StatelessWidget {
  final Widget child;
  final String moduleName;
  final Color? titleBarColor;
  final Color? buttonColor;
  final Color? buttonHoverColor;
  final bool showMinimize;
  final bool showMaximize;
  final bool showClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;

  const ModuleWrapperWithCustomFrame({
    super.key,
    required this.child,
    required this.moduleName,
    this.titleBarColor,
    this.buttonColor,
    this.buttonHoverColor,
    this.showMinimize = true,
    this.showMaximize = true,
    this.showClose = true,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar
          CustomTitleBar(
            title: 'Cat Hotel POS - $moduleName',
            backgroundColor: titleBarColor ?? Colors.indigo[700],
            onMinimize: showMinimize ? (onMinimize ?? () async => await windowManager.minimize()) : null,
            onMaximize: showMaximize ? (onMaximize ?? () async => await windowManager.maximize()) : null,
            onClose: showClose ? (onClose ?? () async => await windowManager.close()) : null,
          ),
          
          // Module Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// A specialized wrapper for full-screen modules with advanced window controls
class FullScreenModuleWrapper extends StatelessWidget {
  final Widget child;
  final String moduleName;
  final Color? backgroundColor;
  final Color? titleBarColor;
  final Color? buttonColor;
  final Color? buttonHoverColor;
  final bool showSystemTray;
  final VoidCallback? onMinimizeToTray;

  const FullScreenModuleWrapper({
    super.key,
    required this.child,
    required this.moduleName,
    this.backgroundColor,
    this.titleBarColor,
    this.buttonColor,
    this.buttonHoverColor,
    this.showSystemTray = false,
    this.onMinimizeToTray,
  });

  @override
  Widget build(BuildContext context) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS - $moduleName',
      backgroundColor: backgroundColor,
      titleBarColor: titleBarColor ?? Colors.indigo[700],
      buttonColor: buttonColor,
      buttonHoverColor: buttonHoverColor,
      showSystemTray: showSystemTray,
      onMinimizeToTray: onMinimizeToTray,
      child: child,
    );
  }
}

/// A simple title bar wrapper for quick integration
class SimpleTitleBarWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const SimpleTitleBarWrapper({
    super.key,
    required this.child,
    required this.title,
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Simple Title Bar
          Container(
            height: 48,
            color: backgroundColor ?? Colors.grey[800],
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Usage Examples and Helper Functions
class CustomFrameHelpers {
  /// Create a module wrapper with default settings
  static Widget wrapModule({
    required Widget child,
    required String moduleName,
    Color? titleBarColor,
  }) {
    return ModuleWrapperWithCustomFrame(
      child: child,
      moduleName: moduleName,
      titleBarColor: titleBarColor,
    );
  }

  /// Create a full-screen module wrapper
  static Widget wrapFullScreenModule({
    required Widget child,
    required String moduleName,
    Color? titleBarColor,
    bool showSystemTray = false,
  }) {
    return FullScreenModuleWrapper(
      child: child,
      moduleName: moduleName,
      titleBarColor: titleBarColor,
      showSystemTray: showSystemTray,
    );
  }

  /// Create a simple title bar wrapper
  static Widget wrapWithSimpleTitleBar({
    required Widget child,
    required String title,
    Color? backgroundColor,
    List<Widget>? actions,
  }) {
    return SimpleTitleBarWrapper(
      child: child,
      title: title,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  /// Get default color scheme for different module types
  static Color getModuleColor(String moduleType) {
    switch (moduleType.toLowerCase()) {
      case 'pos':
      case 'point of sale':
        return Colors.blue[700]!;
      case 'inventory':
      case 'stock':
        return Colors.orange[700]!;
      case 'customers':
      case 'crm':
        return Colors.green[700]!;
      case 'reports':
      case 'analytics':
        return Colors.purple[700]!;
      case 'settings':
      case 'configuration':
        return Colors.grey[700]!;
      case 'financials':
      case 'accounting':
        return Colors.teal[700]!;
      case 'booking':
      case 'reservations':
        return Colors.red[700]!;
      default:
        return Colors.indigo[700]!;
    }
  }
}
