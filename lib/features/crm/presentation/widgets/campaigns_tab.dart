import 'package:flutter/material.dart';
import '../../../../core/services/crm_dao.dart';
import '../../domain/entities/campaign.dart';

class CampaignsTab extends StatefulWidget {
  final CrmDao crmDao;

  const CampaignsTab({super.key, required this.crmDao});

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CampaignType? _selectedType;
  CampaignStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final campaigns = await widget.crmDao.getAllCampaigns();
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading campaigns: $e')),
        );
      }
    }
  }

  List<Campaign> get _filteredCampaigns {
    return _campaigns.where((campaign) {
      final matchesSearch = campaign.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          campaign.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || campaign.type == _selectedType;
      final matchesStatus = _selectedStatus == null || campaign.status == _selectedStatus;
      return matchesSearch && matchesType && matchesStatus;
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
          child: _filteredCampaigns.isEmpty
              ? const Center(child: Text('No campaigns found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = _filteredCampaigns[index];
                    return _buildCampaignCard(campaign);
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
              labelText: 'Search campaigns',
              hintText: 'Search by name or description',
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
                child: DropdownButtonFormField<CampaignType>(
                  decoration: const InputDecoration(
                    labelText: 'Campaign Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...CampaignType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getCampaignTypeDisplay(type)),
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
                child: DropdownButtonFormField<CampaignStatus>(
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
                    ...CampaignStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_getCampaignStatusDisplay(status)),
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
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              _getCampaignTypeIcon(campaign.type),
              color: _getCampaignTypeColor(campaign.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    campaign.description,
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
                color: _getCampaignStatusColor(campaign.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getCampaignStatusDisplay(campaign.status),
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
                _buildCampaignInfo('Type', _getCampaignTypeDisplay(campaign.type)),
                _buildCampaignInfo('Target', _getCampaignTargetDisplay(campaign.target)),
                _buildCampaignInfo('Subject', campaign.subject),
                _buildCampaignInfo('Content', campaign.content),
                _buildCampaignInfo('Total Recipients', '${campaign.totalRecipients}'),
                _buildCampaignInfo('Sent', '${campaign.sentCount}'),
                _buildCampaignInfo('Opened', '${campaign.openedCount}'),
                _buildCampaignInfo('Clicked', '${campaign.clickedCount}'),
                if (campaign.scheduledAt != null)
                  _buildCampaignInfo('Scheduled', _formatDate(campaign.scheduledAt!)),
                if (campaign.sentAt != null)
                  _buildCampaignInfo('Sent At', _formatDate(campaign.sentAt!)),
                _buildCampaignInfo('Created By', campaign.createdBy),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editCampaign(campaign),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleCampaignStatus(campaign),
                        icon: Icon(
                          campaign.status == CampaignStatus.active ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(
                          campaign.status == CampaignStatus.active ? 'Pause' : 'Activate',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCampaignAnalytics(campaign),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analytics'),
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

  Widget _buildCampaignInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getCampaignTypeIcon(CampaignType type) {
    switch (type) {
      case CampaignType.email:
        return Icons.email;
      case CampaignType.sms:
        return Icons.sms;
      case CampaignType.whatsapp:
        return Icons.message;
      case CampaignType.push:
        return Icons.notifications;
    }
  }

  Color _getCampaignTypeColor(CampaignType type) {
    switch (type) {
      case CampaignType.email:
        return Colors.blue;
      case CampaignType.sms:
        return Colors.green;
      case CampaignType.whatsapp:
        return Colors.green;
      case CampaignType.push:
        return Colors.orange;
    }
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

  String _getCampaignTypeDisplay(CampaignType type) {
    switch (type) {
      case CampaignType.email:
        return 'Email';
      case CampaignType.sms:
        return 'SMS';
      case CampaignType.whatsapp:
        return 'WhatsApp';
      case CampaignType.push:
        return 'Push Notification';
    }
  }

  String _getCampaignStatusDisplay(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.scheduled:
        return 'Scheduled';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
      case CampaignStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getCampaignTargetDisplay(CampaignTarget target) {
    switch (target) {
      case CampaignTarget.allCustomers:
        return 'All Customers';
      case CampaignTarget.specificTier:
        return 'Specific Tier';
      case CampaignTarget.specificSegment:
        return 'Specific Segment';
      case CampaignTarget.recentBookings:
        return 'Recent Bookings';
      case CampaignTarget.expiringVaccinations:
        return 'Expiring Vaccinations';
      case CampaignTarget.loyaltyMembers:
        return 'Loyalty Members';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editCampaign(Campaign campaign) {
    // TODO: Implement edit campaign dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit campaign: ${campaign.name}')),
    );
  }

  void _toggleCampaignStatus(Campaign campaign) {
    // TODO: Implement toggle campaign status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          campaign.status == CampaignStatus.active ? 'Pausing campaign' : 'Activating campaign',
        ),
      ),
    );
  }

  void _viewCampaignAnalytics(Campaign campaign) {
    // TODO: Implement campaign analytics view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View analytics for: ${campaign.name}')),
    );
  }
}
