import 'package:flutter/material.dart';
import '../../../../core/services/crm_dao.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/communication_template.dart';
import '../../domain/entities/automated_reminder.dart';
import '../widgets/campaigns_tab.dart';
import '../widgets/communication_templates_tab.dart';
import '../widgets/automated_reminders_tab.dart';
import '../widgets/crm_analytics_tab.dart';

class CrmManagementScreen extends StatefulWidget {
  const CrmManagementScreen({super.key});

  @override
  State<CrmManagementScreen> createState() => _CrmManagementScreenState();
}

class _CrmManagementScreenState extends State<CrmManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CrmDao _crmDao = CrmDao();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _crmDao.init();
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
        title: const Text('CRM Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Campaigns', icon: Icon(Icons.campaign)),
                                    Tab(text: 'Templates', icon: Icon(Icons.description)),
            Tab(text: 'Reminders', icon: Icon(Icons.notifications)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CampaignsTab(crmDao: _crmDao),
          CommunicationTemplatesTab(crmDao: _crmDao),
          AutomatedRemindersTab(crmDao: _crmDao),
          CrmAnalyticsTab(crmDao: _crmDao),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Create New Campaign'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement create new campaign dialog
              },
            ),
                                    ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Create New Template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement create new template dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Schedule Reminder'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement schedule reminder dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Send Quick Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement send quick message dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}
