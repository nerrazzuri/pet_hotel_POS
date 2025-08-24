import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';

/// Example of how to use custom window frame components within the app
/// This approach avoids Directionality issues by working within the MaterialApp context
class CustomWindowFrameUsageExample extends StatelessWidget {
  const CustomWindowFrameUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Window Frame Demo'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Option 1: Use the full CustomWindowFrame within a screen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Option 1: Full Custom Window Frame',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: CustomWindowFrame(
              title: 'Custom Window Frame Demo',
              titleBarColor: Colors.grey[900],
              buttonColor: Colors.transparent,
              buttonHoverColor: Colors.grey[800],
              child: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    Text('This is a custom window frame within the app'),
                    SizedBox(height: 16),
                    Text('It has minimize, maximize, and close buttons'),
                    SizedBox(height: 16),
                    Text('And it works without Directionality issues!'),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Option 2: Use the simple CustomTitleBar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Option 2: Simple Custom Title Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CustomTitleBar(
            title: 'Simple Title Bar',
            backgroundColor: Colors.blue[700],
            onMinimize: () async => await windowManager.minimize(),
            onMaximize: () async => await windowManager.maximize(),
            onClose: () async => await windowManager.close(),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16),
            child: const Text('This is content below the simple title bar'),
          ),
        ],
      ),
    );
  }
}

/// Example of how to integrate custom window frame into existing screens
class DashboardWithCustomFrame extends StatelessWidget {
  const DashboardWithCustomFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom title bar at the top
          CustomTitleBar(
            title: 'Cat Hotel POS System',
            backgroundColor: Colors.teal[700],
            onMinimize: () async => await windowManager.minimize(),
            onMaximize: () async => await windowManager.maximize(),
            onClose: () async => await windowManager.close(),
          ),
          
          // Main dashboard content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Welcome to your Cat Hotel POS System!'),
                  SizedBox(height: 16),
                  Text('This screen has a custom title bar with window controls.'),
                  SizedBox(height: 16),
                  Text('You can minimize, maximize, or close the window from here.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example of how to create a custom window frame for specific modules
class ModuleWithCustomFrame extends StatelessWidget {
  final String moduleName;
  final Widget content;
  
  const ModuleWithCustomFrame({
    super.key,
    required this.moduleName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Module-specific custom title bar
          CustomTitleBar(
            title: 'Cat Hotel POS - $moduleName',
            backgroundColor: Colors.indigo[700],
            onMinimize: () async => await windowManager.minimize(),
            onMaximize: () async => await windowManager.maximize(),
            onClose: () async => await windowManager.close(),
          ),
          
          // Module content
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Example of how to use the custom window frame in a login screen
class LoginWithCustomFrame extends StatelessWidget {
  const LoginWithCustomFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom title bar for login
          CustomTitleBar(
            title: 'Cat Hotel POS - Login',
            backgroundColor: Colors.teal[700],
            onClose: () async => await windowManager.close(),
          ),
          
          // Login content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: Colors.teal,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Cat Hotel POS System',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Professional Point of Sale for Cat Hotels',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 48),
                  Text(
                    'Login functionality would go here...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
