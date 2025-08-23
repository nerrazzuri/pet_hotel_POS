import 'package:flutter/material.dart';
import '../../../../core/services/crm_dao.dart';
import '../../domain/entities/automated_reminder.dart';

class AutomatedRemindersTab extends StatefulWidget {
  final CrmDao crmDao;

  const AutomatedRemindersTab({super.key, required this.crmDao});

  @override
  State<AutomatedRemindersTab> createState() => _AutomatedRemindersTabState();
}

class _AutomatedRemindersTabState extends State<AutomatedRemindersTab> {
  List<AutomatedReminder> _reminders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ReminderType? _selectedType;
  ReminderStatus? _selectedStatus;
  ReminderChannel? _selectedChannel;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await widget.crmDao.getAllReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  List<AutomatedReminder> get _filteredReminders {
    return _reminders.where((reminder) {
      final matchesSearch = reminder.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reminder.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || reminder.type == _selectedType;
      final matchesStatus = _selectedStatus == null || reminder.status == _selectedStatus;
      final matchesChannel = _selectedChannel == null || reminder.channel == _selectedChannel;
      return matchesSearch && matchesType && matchesStatus && matchesChannel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _filteredReminders.isEmpty
              ? const Center(child: Text('No reminders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _filteredReminders[index];
                    return _buildReminderCard(reminder);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search reminders',
              hintText: 'Search by subject or message',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ReminderType>(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...ReminderType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getReminderTypeDisplay(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<ReminderStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...ReminderStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getReminderStatusDisplay(status)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReminderChannel>(
            decoration: const InputDecoration(
              labelText: 'Channel',
              border: OutlineInputBorder(),
            ),
            value: _selectedChannel,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Channels'),
              ),
              ...ReminderChannel.values.map((channel) => DropdownMenuItem(
                value: channel,
                child: Text(_getReminderChannelDisplay(channel)),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedChannel = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(AutomatedReminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              _getReminderTypeIcon(reminder.type),
              color: _getReminderTypeColor(reminder.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Customer: ${reminder.customerId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getReminderStatusColor(reminder.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getReminderStatusDisplay(reminder.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReminderInfo('Type', _getReminderTypeDisplay(reminder.type)),
                _buildReminderInfo('Channel', _getReminderChannelDisplay(reminder.channel)),
                _buildReminderInfo('Customer ID', reminder.customerId),
                if (reminder.petId != null)
                  _buildReminderInfo('Pet ID', reminder.petId!),
                _buildReminderInfo('Message', reminder.message),
                _buildReminderInfo('Scheduled', _formatDate(reminder.scheduledAt)),
                if (reminder.sentAt != null)
                  _buildReminderInfo('Sent At', _formatDate(reminder.sentAt!)),
                _buildReminderInfo('Retry Count', '${reminder.retryCount}'),
                if (reminder.errorMessage != null)
                  _buildReminderInfo('Error', reminder.errorMessage!),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editReminder(reminder),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rescheduleReminder(reminder),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteReminder(reminder),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.vaccinationExpiry:
        return Icons.vaccines;
      case ReminderType.upcomingBooking:
        return Icons.calendar_today;
      case ReminderType.checkInPrep:
        return Icons.login;
      case ReminderType.checkOut:
        return Icons.logout;
      case ReminderType.loyaltyPointsExpiry:
        return Icons.card_giftcard;
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.followUp:
        return Icons.follow_the_signs;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  Color _getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.vaccinationExpiry:
        return Colors.red;
      case ReminderType.upcomingBooking:
        return Colors.blue;
      case ReminderType.checkInPrep:
        return Colors.green;
      case ReminderType.checkOut:
        return Colors.orange;
      case ReminderType.loyaltyPointsExpiry:
        return Colors.purple;
      case ReminderType.birthday:
        return Colors.pink;
      case ReminderType.followUp:
        return Colors.teal;
      case ReminderType.custom:
        return Colors.grey;
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

  String _getReminderTypeDisplay(ReminderType type) {
    switch (type) {
      case ReminderType.vaccinationExpiry:
        return 'Vaccination Expiry';
      case ReminderType.upcomingBooking:
        return 'Upcoming Booking';
      case ReminderType.checkInPrep:
        return 'Check-in Prep';
      case ReminderType.checkOut:
        return 'Check-out';
      case ReminderType.loyaltyPointsExpiry:
        return 'Loyalty Points Expiry';
      case ReminderType.birthday:
        return 'Birthday';
      case ReminderType.followUp:
        return 'Follow-up';
      case ReminderType.custom:
        return 'Custom';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editReminder(AutomatedReminder reminder) {
    // TODO: Implement edit reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit reminder: ${reminder.subject}')),
    );
  }

  void _rescheduleReminder(AutomatedReminder reminder) {
    // TODO: Implement reschedule reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reschedule reminder: ${reminder.subject}')),
    );
  }

  void _deleteReminder(AutomatedReminder reminder) {
    // TODO: Implement delete reminder confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete reminder: ${reminder.subject}')),
    );
  }
}
