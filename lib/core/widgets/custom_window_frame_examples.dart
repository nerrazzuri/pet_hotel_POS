import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';

/// Example configurations for the CustomWindowFrame
class CustomWindowFrameExamples {
  
  /// Default dark theme window frame
  static Widget defaultDarkTheme(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: Colors.grey[900],
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.grey[800],
      child: child,
    );
  }

  /// Light theme window frame
  static Widget lightTheme(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: Colors.grey[100],
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.grey[200],
      child: child,
    );
  }

  /// Blue theme window frame
  static Widget blueTheme(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: Colors.blue[700],
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.blue[600],
      child: child,
    );
  }

  /// Teal theme window frame (matching your app theme)
  static Widget tealTheme(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: Colors.teal[700],
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.teal[600],
      child: child,
    );
  }

  /// Premium dark theme with system tray support
  static Widget premiumDarkTheme(Widget child, {VoidCallback? onMinimizeToTray}) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System - Premium',
      titleBarColor: const Color(0xFF1a1a1a),
      buttonColor: Colors.transparent,
      buttonHoverColor: const Color(0xFF2d2d2d),
      showSystemTray: true,
      onMinimizeToTray: onMinimizeToTray,
      child: child,
    );
  }

  /// Custom branded theme
  static Widget brandedTheme(Widget child, {
    required String title,
    required Color primaryColor,
    required Color accentColor,
  }) {
    return CustomWindowFrame(
      title: title,
      titleBarColor: primaryColor,
      buttonColor: Colors.transparent,
      buttonHoverColor: accentColor,
      child: child,
    );
  }
}

/// Usage examples and documentation
class CustomWindowFrameUsage {
  
  /// Basic usage example
  static Widget basicExample() {
    return CustomWindowFrame(
      title: 'My App',
      child: const Scaffold(
        body: Center(
          child: Text('Your app content here'),
        ),
      ),
    );
  }

  /// Advanced usage with custom colors and system tray
  static Widget advancedExample() {
    return CustomWindowFrame(
      title: 'Advanced App',
      titleBarColor: const Color(0xFF2C3E50),
      buttonColor: Colors.transparent,
      buttonHoverColor: const Color(0xFF34495E),
      showSystemTray: true,
      onMinimizeToTray: () {
        // Handle minimize to tray
        print('Minimizing to system tray...');
      },
      child: const Scaffold(
        body: Center(
          child: Text('Advanced app with system tray support'),
        ),
      ),
    );
  }

  /// Theme switching example
  static Widget themeSwitchingExample() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isDarkTheme = true;
        
        return CustomWindowFrame(
          title: 'Theme Switching App',
          titleBarColor: isDarkTheme ? Colors.grey[900] : Colors.grey[100],
          buttonColor: Colors.transparent,
          buttonHoverColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Click to switch themes'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isDarkTheme = !isDarkTheme;
                      });
                    },
                    child: Text('Switch to ${isDarkTheme ? 'Light' : 'Dark'} Theme'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Configuration presets for different use cases
class WindowFramePresets {
  
  /// Professional business application
  static Widget professionalBusiness(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: const Color(0xFF2C3E50),
      buttonColor: Colors.transparent,
      buttonHoverColor: const Color(0xFF34495E),
      child: child,
    );
  }

  /// Modern web app style
  static Widget modernWebApp(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: Colors.white,
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.grey[100],
      child: child,
    );
  }

  /// Gaming/Entertainment app style
  static Widget gamingStyle(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS System',
      titleBarColor: const Color(0xFF1a1a1a),
      buttonColor: Colors.transparent,
      buttonHoverColor: const Color(0xFF4a4a4a),
      child: child,
    );
  }

  /// Minimalist style
  static Widget minimalist(Widget child) {
    return CustomWindowFrame(
      title: 'Cat Hotel POS',
      titleBarColor: Colors.transparent,
      buttonColor: Colors.transparent,
      buttonHoverColor: Colors.black.withOpacity(0.1),
      child: child,
    );
  }
}
