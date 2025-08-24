import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

class CommunicationHistoryWidget extends ConsumerStatefulWidget {
  const CommunicationHistoryWidget({super.key});

  @override
  ConsumerState<CommunicationHistoryWidget> createState() => _CommunicationHistoryWidgetState();
}

class _CommunicationHistoryWidgetState extends ConsumerState<CommunicationHistoryWidget> {
  final CustomerDao _customerDao = CustomerDao();
  String _selectedCommunicationType = 'all';
  String _selectedStatus = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Customer>>(
      future: _customerDao.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading communication data: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final customers = snapshot.data ?? [];
        final communicationData = _generateCommunicationData(customers);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Communication Overview
              _buildCommunicationOverview(communicationData),
              const SizedBox(height: 24),

              // Controls
              _buildControls(),
              const SizedBox(height: 24),

              // Communication History List
              _buildCommunicationHistoryList(communicationData),
              const SizedBox(height: 24),

              // Communication Templates
              _buildCommunicationTemplates(),
              const SizedBox(height: 24),

              // Scheduled Communications
              _buildScheduledCommunications(communicationData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.message, size: 32, color: Colors.indigo),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Communication Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Track and manage all customer communications',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _sendNewMessage,
          icon: const Icon(Icons.send),
          label: const Text('Send Message'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _scheduleCommunication,
          icon: const Icon(Icons.schedule),
          label: const Text('Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationOverview(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          'Total Communications',
          '${data['totalCommunications']}',
          Icons.message,
          Colors.blue,
          subtitle: 'This month',
        ),
        _buildMetricCard(
          'Successful',
          '${data['successfulCommunications']}',
          Icons.check_circle,
          Colors.green,
          subtitle: '${data['successRate']}% success rate',
        ),
        _buildMetricCard(
          'Pending',
          '${data['pendingCommunications']}',
          Icons.schedule,
          Colors.orange,
          subtitle: 'Awaiting response',
        ),
        _buildMetricCard(
          'Failed',
          '${data['failedCommunications']}',
          Icons.error,
          Colors.red,
          subtitle: '${data['failureRate']}% failure rate',
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Type: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedCommunicationType,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'sms', child: Text('SMS')),
                DropdownMenuItem(value: 'phone', child: Text('Phone Call')),
                DropdownMenuItem(value: 'in_app', child: Text('In-App')),
                DropdownMenuItem(value: 'social', child: Text('Social Media')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCommunicationType = value;
                  });
                }
              },
            ),
            const SizedBox(width: 32),
            const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedStatus,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'sent', child: Text('Sent')),
                DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                DropdownMenuItem(value: 'read', child: Text('Read')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(width: 32),
            const Text('Date Range: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedDateRange != null
                      ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                      : 'Select Range',
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exportCommunicationReport,
              icon: const Icon(Icons.download),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationHistoryList(Map<String, dynamic> data) {
    final communications = data['communications'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Communication History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${communications.length} communications',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: communications.length,
                itemBuilder: (context, index) {
                  final communication = communications[index];
                  return _buildCommunicationCard(communication);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationCard(Map<String, dynamic> communication) {
    final type = communication['type'] as String;
    final status = communication['status'] as String;
    final typeColor = _getCommunicationTypeColor(type);
    final statusColor = _getStatusColor(status);
    final typeIcon = _getCommunicationTypeIcon(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          communication['subject'] ?? 'No Subject',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${communication['customerName']} • ${communication['customerEmail']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(communication['timestamp']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCommunicationAction(value, communication),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'resend',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Resend'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reply',
              child: Row(
                children: [
                  Icon(Icons.reply),
                  SizedBox(width: 8),
                  Text('Reply'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'forward',
              child: Row(
                children: [
                  Icon(Icons.forward),
                  SizedBox(width: 8),
                  Text('Forward'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        onTap: () => _viewCommunicationDetails(communication),
      ),
    );
  }

  Widget _buildCommunicationTemplates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Communication Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _createNewTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Template'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTemplateCard(
                    'Welcome Email',
                    'Sent to new customers',
                    Icons.email,
                    Colors.blue,
                    ['Personalized greeting', 'Service overview', 'Contact information'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTemplateCard(
                    'Appointment Reminder',
                    '24h before booking',
                    Icons.schedule,
                    Colors.orange,
                    ['Booking details', 'Location info', 'What to bring'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTemplateCard(
                    'Follow-up Survey',
                    'After service completion',
                    Icons.rate_review,
                    Colors.green,
                    ['Service feedback', 'Rating request', 'Future booking'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTemplateCard(
                    'Special Offers',
                    'Promotional campaigns',
                    Icons.local_offer,
                    Colors.purple,
                    ['Limited time deals', 'Exclusive discounts', 'Call to action'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(String title, String description, IconData icon, Color color, List<String> features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 14, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _editTemplate(title),
                  child: const Text('Edit'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _useTemplate(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Use'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledCommunications(Map<String, dynamic> data) {
    final scheduled = data['scheduledCommunications'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Scheduled Communications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${scheduled.length} scheduled',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (scheduled.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No scheduled communications',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Schedule communications to be sent automatically',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scheduled.length,
                itemBuilder: (context, index) {
                  final scheduledComm = scheduled[index];
                  return _buildScheduledCommunicationCard(scheduledComm);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledCommunicationCard(Map<String, dynamic> scheduledComm) {
    final type = scheduledComm['type'] as String;
    final typeColor = _getCommunicationTypeColor(type);
    final typeIcon = _getCommunicationTypeIcon(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          scheduledComm['subject'] ?? 'No Subject',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${scheduledComm['customerName']} • ${scheduledComm['customerEmail']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.schedule, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Scheduled for ${_formatTimestamp(scheduledComm['scheduledTime'])}',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleScheduledAction(value, scheduledComm),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel),
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'send_now',
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Send Now'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  // Helper methods
  Color _getCommunicationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Colors.blue;
      case 'sms':
        return Colors.green;
      case 'phone':
        return Colors.orange;
      case 'in_app':
        return Colors.purple;
      case 'social':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCommunicationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'phone':
        return Icons.phone;
      case 'in_app':
        return Icons.notifications;
      case 'social':
        return Icons.share;
      default:
        return Icons.message;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'read':
        return Colors.teal;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Map<String, dynamic> _generateCommunicationData(List<Customer> customers) {
    // Simulate communication data for demo
    final totalCommunications = customers.length * 3;
    final successfulCommunications = (totalCommunications * 0.85).round();
    final pendingCommunications = (totalCommunications * 0.10).round();
    final failedCommunications = totalCommunications - successfulCommunications - pendingCommunications;
    
    final successRate = totalCommunications > 0 ? (successfulCommunications / totalCommunications * 100).round() : 0;
    final failureRate = totalCommunications > 0 ? (failedCommunications / totalCommunications * 100).round() : 0;

    // Generate sample communications
    final communications = List.generate(
      totalCommunications.clamp(0, 50), // Limit to 50 for demo
      (index) {
        final customer = customers[index % customers.length];
        final types = ['email', 'sms', 'phone', 'in_app', 'social'];
        final statuses = ['sent', 'delivered', 'read', 'failed', 'pending'];
        
        return {
          'id': 'comm_$index',
          'type': types[index % types.length],
          'status': statuses[index % statuses.length],
          'subject': _getRandomSubject(index),
          'customerName': '${customer.firstName} ${customer.lastName}',
          'customerEmail': customer.email,
          'timestamp': DateTime.now().subtract(Duration(hours: index * 2)),
        };
      },
    );

    // Generate sample scheduled communications
    final scheduledCommunications = List.generate(
      (customers.length * 0.3).round().clamp(0, 10), // 30% of customers, max 10
      (index) {
        final customer = customers[index % customers.length];
        final types = ['email', 'sms'];
        
        return {
          'id': 'scheduled_$index',
          'type': types[index % types.length],
          'subject': _getRandomScheduledSubject(index),
          'customerName': '${customer.firstName} ${customer.lastName}',
          'customerEmail': customer.email,
          'scheduledTime': DateTime.now().add(Duration(hours: (index + 1) * 6)),
        };
      },
    );

    return {
      'totalCommunications': totalCommunications,
      'successfulCommunications': successfulCommunications,
      'pendingCommunications': pendingCommunications,
      'failedCommunications': failedCommunications,
      'successRate': successRate,
      'failureRate': failureRate,
      'communications': communications,
      'scheduledCommunications': scheduledCommunications,
    };
  }

  String _getRandomSubject(int index) {
    final subjects = [
      'Welcome to Cat Hotel!',
      'Appointment Confirmation',
      'Service Reminder',
      'Thank You for Your Visit',
      'Special Offer Just for You',
      'Pet Care Tips',
      'Booking Update',
      'Customer Satisfaction Survey',
      'Holiday Hours',
      'New Services Available',
    ];
    return subjects[index % subjects.length];
  }

  String _getRandomScheduledSubject(int index) {
    final subjects = [
      'Appointment Reminder',
      'Follow-up Survey',
      'Special Promotion',
      'Pet Care Newsletter',
      'Birthday Wishes',
    ];
    return subjects[index % subjects.length];
  }

  // Action methods
  void _sendNewMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send new message dialog coming soon!')),
    );
  }

  void _scheduleCommunication() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule communication dialog coming soon!')),
    );
  }

  void _exportCommunicationReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting communication report...')),
    );
  }

  void _createNewTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create new template dialog coming soon!')),
    );
  }

  void _editTemplate(String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing template: $templateName')),
    );
  }

  void _useTemplate(String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Using template: $templateName')),
    );
  }

  void _handleCommunicationAction(String action, Map<String, dynamic> communication) {
    switch (action) {
      case 'view':
        _viewCommunicationDetails(communication);
        break;
      case 'resend':
        _resendCommunication(communication);
        break;
      case 'reply':
        _replyToCommunication(communication);
        break;
      case 'forward':
        _forwardCommunication(communication);
        break;
    }
  }

  void _handleScheduledAction(String action, Map<String, dynamic> scheduledComm) {
    switch (action) {
      case 'edit':
        _editScheduledCommunication(scheduledComm);
        break;
      case 'cancel':
        _cancelScheduledCommunication(scheduledComm);
        break;
      case 'send_now':
        _sendScheduledCommunicationNow(scheduledComm);
        break;
    }
  }

  void _viewCommunicationDetails(Map<String, dynamic> communication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${communication['subject']}')),
    );
  }

  void _resendCommunication(Map<String, dynamic> communication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resending: ${communication['subject']}')),
    );
  }

  void _replyToCommunication(Map<String, dynamic> communication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Replying to: ${communication['subject']}')),
    );
  }

  void _forwardCommunication(Map<String, dynamic> communication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forwarding: ${communication['subject']}')),
    );
  }

  void _editScheduledCommunication(Map<String, dynamic> scheduledComm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing scheduled: ${scheduledComm['subject']}')),
    );
  }

  void _cancelScheduledCommunication(Map<String, dynamic> scheduledComm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelling scheduled: ${scheduledComm['subject']}')),
    );
  }

  void _sendScheduledCommunicationNow(Map<String, dynamic> scheduledComm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending now: ${scheduledComm['subject']}')),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}
