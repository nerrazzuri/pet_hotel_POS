import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

class LoyaltyTrackingWidget extends ConsumerStatefulWidget {
  const LoyaltyTrackingWidget({super.key});

  @override
  ConsumerState<LoyaltyTrackingWidget> createState() => _LoyaltyTrackingWidgetState();
}

class _LoyaltyTrackingWidgetState extends ConsumerState<LoyaltyTrackingWidget> {
  final CustomerDao _customerDao = CustomerDao();
  String _selectedLoyaltyTier = 'all';
  String _selectedSortBy = 'points';

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
                Text('Error loading loyalty data: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final customers = snapshot.data ?? [];
        final loyaltyData = _calculateLoyaltyData(customers);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Loyalty Overview
              _buildLoyaltyOverview(loyaltyData),
              const SizedBox(height: 24),

              // Controls
              _buildControls(),
              const SizedBox(height: 24),

              // Loyalty Members List
              _buildLoyaltyMembersList(loyaltyData),
              const SizedBox(height: 24),

              // Loyalty Program Stats
              _buildLoyaltyProgramStats(loyaltyData),
              const SizedBox(height: 24),

              // Rewards and Benefits
              _buildRewardsAndBenefits(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.card_giftcard, size: 32, color: Colors.teal),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loyalty Program Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Track customer loyalty, points, and rewards',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _addLoyaltyMember,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Member'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _manageRewards,
          icon: const Icon(Icons.card_giftcard),
          label: const Text('Manage Rewards'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyOverview(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildLoyaltyCard(
          'Total Members',
          '${data['totalMembers']}',
          Icons.people,
          Colors.blue,
          subtitle: '${data['membershipRate']}% of customers',
        ),
        _buildLoyaltyCard(
          'Active Members',
          '${data['activeMembers']}',
          Icons.person,
          Colors.green,
          subtitle: '${data['activeRate']}% active',
        ),
        _buildLoyaltyCard(
          'Total Points Issued',
          '${data['totalPointsIssued']}',
          Icons.stars,
          Colors.amber,
          subtitle: 'This month',
        ),
        _buildLoyaltyCard(
          'Points Redeemed',
          '${data['pointsRedeemed']}',
          Icons.redeem,
          Colors.purple,
          subtitle: 'This month',
        ),
      ],
    );
  }

  Widget _buildLoyaltyCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
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
            const Text('Loyalty Tier: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedLoyaltyTier,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Tiers')),
                DropdownMenuItem(value: 'bronze', child: Text('Bronze')),
                DropdownMenuItem(value: 'silver', child: Text('Silver')),
                DropdownMenuItem(value: 'gold', child: Text('Gold')),
                DropdownMenuItem(value: 'platinum', child: Text('Platinum')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLoyaltyTier = value;
                  });
                }
              },
            ),
            const SizedBox(width: 32),
            const Text('Sort By: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedSortBy,
              items: [
                DropdownMenuItem(value: 'points', child: Text('Points')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'tier', child: Text('Tier')),
                DropdownMenuItem(value: 'join_date', child: Text('Join Date')),
                DropdownMenuItem(value: 'last_activity', child: Text('Last Activity')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSortBy = value;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exportLoyaltyReport,
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

  Widget _buildLoyaltyMembersList(Map<String, dynamic> data) {
    final members = data['loyaltyMembers'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Loyalty Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${members.length} members',
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
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _buildLoyaltyMemberCard(member);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyMemberCard(Map<String, dynamic> member) {
    final tier = member['tier'] as String;
    final tierColor = _getTierColor(tier);
    final tierIcon = _getTierIcon(tier);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tierColor.withOpacity(0.1),
          child: Icon(tierIcon, color: tierColor),
        ),
        title: Text(
          member['name'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member['email']} • ${member['phone']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tierColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    tier.toUpperCase(),
                    style: TextStyle(
                      color: tierColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${member['points']} points',
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
          onSelected: (value) => _handleMemberAction(value, member),
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
              value: 'points',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Points'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'redeem',
              child: Row(
                children: [
                  Icon(Icons.redeem),
                  SizedBox(width: 8),
                  Text('Redeem Points'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        onTap: () => _viewMemberDetails(member),
      ),
    );
  }

  Widget _buildLoyaltyProgramStats(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Points Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPointsDistributionChart(data['pointsDistribution']),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tier Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildTierDistributionChart(data['tierDistribution']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsDistributionChart(Map<String, int> distribution) {
    // Placeholder for chart implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Points Distribution',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Chart implementation coming soon',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierDistributionChart(Map<String, int> distribution) {
    // Placeholder for chart implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Tier Distribution',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Chart implementation coming soon',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsAndBenefits() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Rewards & Benefits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addNewReward,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reward'),
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
                  child: _buildRewardCard(
                    'Bronze Tier',
                    '0-999 points',
                    [
                      '5% discount on grooming',
                      'Free nail trim',
                      'Birthday treat',
                    ],
                    Colors.brown,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRewardCard(
                    'Silver Tier',
                    '1000-2499 points',
                    [
                      '10% discount on boarding',
                      'Free bath with grooming',
                      'Priority booking',
                      'Quarterly newsletter',
                    ],
                    Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRewardCard(
                    'Gold Tier',
                    '2500-4999 points',
                    [
                      '15% discount on all services',
                      'Free overnight stay',
                      'VIP customer service',
                      'Monthly special offers',
                    ],
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRewardCard(
                    'Platinum Tier',
                    '5000+ points',
                    [
                      '20% discount on all services',
                      'Free premium services',
                      'Dedicated pet concierge',
                      'Exclusive events access',
                    ],
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(String tier, String requirement, List<String> benefits, Color color) {
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
              Icon(_getTierIcon(tier.toLowerCase()), color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                tier,
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
            requirement,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Icons.star_border;
      case 'silver':
        return Icons.star_half;
      case 'gold':
        return Icons.star;
      case 'platinum':
        return Icons.star_rate;
      default:
        return Icons.star_border;
    }
  }

  Map<String, dynamic> _calculateLoyaltyData(List<Customer> customers) {
    // Simulate loyalty data for demo
    final totalMembers = (customers.length * 0.75).round();
    final activeMembers = (totalMembers * 0.85).round();
    final membershipRate = customers.isNotEmpty ? (totalMembers / customers.length * 100).round() : 0;
    final activeRate = totalMembers > 0 ? (activeMembers / totalMembers * 100).round() : 0;
    
    final totalPointsIssued = totalMembers * 1500;
    final pointsRedeemed = totalMembers * 300;

    // Generate sample loyalty members
    final loyaltyMembers = List.generate(
      totalMembers.clamp(0, customers.length),
      (index) {
        final customer = customers[index];
        final tier = _getRandomTier();
        final points = _getRandomPoints(tier);
        
        return {
          'id': customer.id,
          'name': '${customer.firstName} ${customer.lastName}',
          'email': customer.email,
          'phone': customer.phoneNumber ?? 'N/A',
          'tier': tier,
          'points': points,
          'joinDate': customer.createdAt,
          'lastActivity': DateTime.now().subtract(Duration(days: index * 3)),
        };
      },
    );

    // Points distribution
    final pointsDistribution = {
      '0-999': (totalMembers * 0.4).round(),
      '1000-2499': (totalMembers * 0.35).round(),
      '2500-4999': (totalMembers * 0.20).round(),
      '5000+': (totalMembers * 0.05).round(),
    };

    // Tier distribution
    final tierDistribution = {
      'Bronze': (totalMembers * 0.4).round(),
      'Silver': (totalMembers * 0.35).round(),
      'Gold': (totalMembers * 0.20).round(),
      'Platinum': (totalMembers * 0.05).round(),
    };

    return {
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'membershipRate': membershipRate,
      'activeRate': activeRate,
      'totalPointsIssued': totalPointsIssued,
      'pointsRedeemed': pointsRedeemed,
      'loyaltyMembers': loyaltyMembers,
      'pointsDistribution': pointsDistribution,
      'tierDistribution': tierDistribution,
    };
  }

  String _getRandomTier() {
    final random = DateTime.now().millisecond % 100;
    if (random < 40) return 'Bronze';
    if (random < 75) return 'Silver';
    if (random < 95) return 'Gold';
    return 'Platinum';
  }

  int _getRandomPoints(String tier) {
    switch (tier) {
      case 'Bronze':
        return 100 + (DateTime.now().millisecond % 900);
      case 'Silver':
        return 1000 + (DateTime.now().millisecond % 1500);
      case 'Gold':
        return 2500 + (DateTime.now().millisecond % 2500);
      case 'Platinum':
        return 5000 + (DateTime.now().millisecond % 5000);
      default:
        return 500;
    }
  }

  // Action methods
  void _addLoyaltyMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add loyalty member dialog coming soon!')),
    );
  }

  void _manageRewards() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage rewards dialog coming soon!')),
    );
  }

  void _exportLoyaltyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting loyalty report...')),
    );
  }

  void _addNewReward() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new reward dialog coming soon!')),
    );
  }

  void _handleMemberAction(String action, Map<String, dynamic> member) {
    switch (action) {
      case 'view':
        _viewMemberDetails(member);
        break;
      case 'edit':
        _editMember(member);
        break;
      case 'points':
        _addPoints(member);
        break;
      case 'redeem':
        _redeemPoints(member);
        break;
    }
  }

  void _viewMemberDetails(Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${member['name']}')),
    );
  }

  void _editMember(Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${member['name']}')),
    );
  }

  void _addPoints(Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adding points for ${member['name']}')),
    );
  }

  void _redeemPoints(Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redeeming points for ${member['name']}')),
    );
  }
}
