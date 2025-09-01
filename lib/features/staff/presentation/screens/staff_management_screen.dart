import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/comprehensive_staff_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/business_owner_time_tracking_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/staff_time_tracking_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/leave_management_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/payroll_management_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/staff_position_management_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/staff_analytics_tab.dart';
import 'package:cat_hotel_pos/features/staff/presentation/widgets/shift_scheduling_tab.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          // Back to Dashboard Button (right side with padding)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                tooltip: 'Back to Dashboard',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: 'Staff Management',
            ),
            Tab(
              icon: Icon(Icons.access_time),
              text: 'Time Tracking',
            ),
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Shift Scheduling',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Leave Management',
            ),
            Tab(
              icon: Icon(Icons.payment),
              text: 'Payroll',
            ),
            Tab(
              icon: Icon(Icons.work_outline),
              text: 'Positions',
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
          ComprehensiveStaffTab(),
          BusinessOwnerTimeTrackingTab(),
          ShiftSchedulingTab(),
          LeaveManagementTab(),
          PayrollManagementTab(),
          StaffPositionManagementTab(),
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
                _tabController.animateTo(0); // Switch to Staff Management tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('View Time Tracking'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1); // Switch to Time Tracking tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.teal),
              title: const Text('Create Shift'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2); // Switch to Shift Scheduling tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Request Leave'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(3); // Switch to Leave Management tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.green),
              title: const Text('Generate Payroll'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(4); // Switch to Payroll tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.work_outline, color: Colors.purple),
              title: const Text('Manage Positions'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(5); // Switch to Positions tab
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.indigo),
              title: const Text('Export Staff Report'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(6); // Switch to Analytics tab
                // TODO: Export staff report
              },
            ),
          ],
        ),
      ),
    );
  }
}
