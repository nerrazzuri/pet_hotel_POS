import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/settings/presentation/widgets/general_settings_tab.dart';
import 'package:cat_hotel_pos/features/settings/presentation/widgets/business_settings_tab.dart';
import 'package:cat_hotel_pos/features/settings/presentation/widgets/notification_settings_tab.dart';
import 'package:cat_hotel_pos/features/settings/presentation/widgets/system_settings_tab.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.business),
              text: 'Business',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'General',
            ),
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Notifications',
            ),
            Tab(
              icon: Icon(Icons.system_update),
              text: 'System',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BusinessSettingsTab(),
          GeneralSettingsTab(),
          NotificationSettingsTab(),
          SystemSettingsTab(),
        ],
      ),
    );
  }
}
