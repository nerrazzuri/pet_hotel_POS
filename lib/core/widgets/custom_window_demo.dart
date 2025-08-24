import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/core/widgets/global_app_wrapper.dart';

/// Demo screen to show how the custom window frame works
/// This demonstrates the automatic title bar integration
class CustomWindowDemo extends StatelessWidget {
  const CustomWindowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalAppHelpers.wrapScreen(
      child: _buildDemoContent(),
      title: 'Custom Window Demo',
      titleBarColor: Colors.purple[700],
    );
  }

  Widget _buildDemoContent() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  '🎉 Custom Window Frame Successfully Implemented!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Every screen in your application now has a custom title bar with minimize, maximize, and close buttons.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ What You Now Have:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    '🎯 Global Integration',
                    'Every screen automatically gets the custom title bar',
                    Colors.blue[100]!,
                    Colors.blue[700]!,
                  ),
                  
                  _buildFeatureCard(
                    '🎨 Smart Colors',
                    'Each module gets its own color scheme automatically',
                    Colors.green[100]!,
                    Colors.green[700]!,
                  ),
                  
                  _buildFeatureCard(
                    '🔧 Window Controls',
                    'Minimize, maximize, and close buttons on every screen',
                    Colors.orange[100]!,
                    Colors.orange[700]!,
                  ),
                  
                  _buildFeatureCard(
                    '📱 Draggable Title Bar',
                    'Move the window by dragging the title bar',
                    Colors.purple[100]!,
                    Colors.purple[700]!,
                  ),
                  
                  _buildFeatureCard(
                    '🚀 No Code Changes',
                    'Your existing screens work without modification',
                    Colors.teal[100]!,
                    Colors.teal[700]!,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // How It Works
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔧 How It Works:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. The GlobalAppWrapper automatically wraps every route in main.dart\n'
                          '2. Each screen gets a custom title bar with appropriate colors\n'
                          '3. Window controls (minimize, maximize, close) work on every screen\n'
                          '4. Your existing screen content is preserved and works exactly the same',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Navigation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🧪 Test It Out:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Navigate to different screens to see the custom title bars in action!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
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

  Widget _buildFeatureCard(String title, String description, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
