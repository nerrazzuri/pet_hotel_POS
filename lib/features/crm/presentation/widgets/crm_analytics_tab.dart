import 'package:flutter/material.dart';
import '../../../../core/services/crm_dao.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/automated_reminder.dart';

class CrmAnalyticsTab extends StatefulWidget {
  final CrmDao crmDao;

  const CrmAnalyticsTab({super.key, required this.crmDao});

  @override
  State<CrmAnalyticsTab> createState() => _CrmAnalyticsTabState();
}

class _CrmAnalyticsTabState extends State<CrmAnalyticsTab> {
  List<Campaign> _campaigns = [];
  List<AutomatedReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final campaigns = await widget.crmDao.getAllCampaigns();
      final reminders = await widget.crmDao.getAllReminders();
      setState(() {
        _campaigns = campaigns;
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildCampaignPerformance(),
          const SizedBox(height: 24),
          _buildReminderEffectiveness(),
          const SizedBox(height: 24),
          _buildChannelDistribution(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalCampaigns = _campaigns.length;
    final activeCampaigns = _campaigns
        .where((c) => c.status == CampaignStatus.active)
        .length;
    final totalReminders = _reminders.length;
    final pendingReminders = _reminders
        .where((r) => r.status == ReminderStatus.pending)
        .length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Campaigns',
          '$totalCampaigns',
          Icons.campaign,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Campaigns',
          '$activeCampaigns',
          Icons.play_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Reminders',
          '$totalReminders',
          Icons.notifications,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Reminders',
          '$pendingReminders',
          Icons.schedule,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignPerformance() {
    final campaignStats = <String, int>{};
    for (final status in CampaignStatus.values) {
      campaignStats[status.name] = _campaigns
          .where((c) => c.status == status)
          .length;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...campaignStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getCampaignStatusDisplay(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: _campaigns.isEmpty ? 0 : entry.value / _campaigns.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCampaignStatusColor(_getCampaignStatusFromString(entry.key)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderEffectiveness() {
    final reminderStats = <String, int>{};
    for (final status in ReminderStatus.values) {
      reminderStats[status.name] = _reminders
          .where((r) => r.status == status)
          .length;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Effectiveness',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...reminderStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getReminderStatusDisplay(_getReminderStatusFromString(entry.key)),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: _reminders.isEmpty ? 0 : entry.value / _reminders.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getReminderStatusColor(_getReminderStatusFromString(entry.key)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelDistribution() {
    final channelStats = <String, int>{};
    for (final channel in ReminderChannel.values) {
      channelStats[channel.name] = _reminders
          .where((r) => r.channel == channel)
          .length;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Communication Channel Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...channelStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _getReminderChannelDisplay(_getReminderChannelFromString(entry.key)),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: _reminders.isEmpty ? 0 : entry.value / _reminders.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getReminderChannelColor(_getReminderChannelFromString(entry.key)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  CampaignStatus _getCampaignStatusFromString(String status) {
    return CampaignStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => CampaignStatus.draft,
    );
  }

  ReminderStatus _getReminderStatusFromString(String status) {
    return ReminderStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => ReminderStatus.pending,
    );
  }

  ReminderChannel _getReminderChannelFromString(String channel) {
    return ReminderChannel.values.firstWhere(
      (c) => c.name == channel,
      orElse: () => ReminderChannel.email,
    );
  }

  Color _getCampaignStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.scheduled:
        return Colors.blue;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.paused:
        return Colors.orange;
      case CampaignStatus.completed:
        return Colors.purple;
      case CampaignStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getReminderStatusColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.pending:
        return Colors.orange;
      case ReminderStatus.sent:
        return Colors.green;
      case ReminderStatus.failed:
        return Colors.red;
      case ReminderStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getReminderChannelColor(ReminderChannel channel) {
    switch (channel) {
      case ReminderChannel.email:
        return Colors.blue;
      case ReminderChannel.sms:
        return Colors.green;
      case ReminderChannel.whatsapp:
        return Colors.green;
      case ReminderChannel.push:
        return Colors.orange;
    }
  }

  String _getCampaignStatusDisplay(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'scheduled':
        return 'Scheduled';
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getReminderStatusDisplay(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.pending:
        return 'Pending';
      case ReminderStatus.sent:
        return 'Sent';
      case ReminderStatus.failed:
        return 'Failed';
      case ReminderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getReminderChannelDisplay(ReminderChannel channel) {
    switch (channel) {
      case ReminderChannel.email:
        return 'Email';
      case ReminderChannel.sms:
        return 'SMS';
      case ReminderChannel.whatsapp:
        return 'WhatsApp';
      case ReminderChannel.push:
        return 'Push Notification';
    }
  }
}
