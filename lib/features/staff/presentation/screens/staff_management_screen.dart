import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/staff_directory_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/shift_scheduling_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/staff_analytics_tab.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Staff Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: 'Staff Directory',
            ),
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Shift Scheduling',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StaffDirectoryTab(),
          ShiftSchedulingTab(),
          StaffAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show context menu for different actions
          _showActionMenu(context);
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.indigo),
              title: const Text('Add New Staff Member'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0); // Switch to Staff Directory tab
                // TODO: Show add staff member dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.indigo),
              title: const Text('Create New Shift'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1); // Switch to Shift Scheduling tab
                // TODO: Show create shift dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.indigo),
              title: const Text('Export Staff Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Export staff report
              },
            ),
          ],
        ),
      ),
    );
  }
}
