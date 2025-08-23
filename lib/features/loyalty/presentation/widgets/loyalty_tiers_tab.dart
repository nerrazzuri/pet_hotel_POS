import 'package:flutter/material.dart';
import '../../../../core/services/loyalty_dao.dart';
import '../../domain/entities/loyalty_program.dart';

class LoyaltyTiersTab extends StatefulWidget {
  final LoyaltyDao loyaltyDao;

  const LoyaltyTiersTab({super.key, required this.loyaltyDao});

  @override
  State<LoyaltyTiersTab> createState() => _LoyaltyTiersTabState();
}

class _LoyaltyTiersTabState extends State<LoyaltyTiersTab> {
  LoyaltyProgram? _activeProgram;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveProgram();
  }

  Future<void> _loadActiveProgram() async {
    setState(() => _isLoading = true);
    try {
      final program = await widget.loyaltyDao.getActiveLoyaltyProgram();
      setState(() {
        _activeProgram = program;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading program: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeProgram == null) {
      return const Center(
        child: Text('No active loyalty program found'),
      );
    }

    final tiers = _activeProgram!.tiers;
    if (tiers.isEmpty) {
      return const Center(
        child: Text('No loyalty tiers found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tiers.length,
      itemBuilder: (context, index) {
        final tier = tiers[index];
        return _buildTierCard(tier, index);
      },
    );
  }

  Widget _buildTierCard(LoyaltyTier tier, int index) {
    final isHighestTier = index == 0;
    final isLowestTier = index == _activeProgram!.tiers.length - 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _getTierColor(tier.color),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tier.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          tier.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(tier.color),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tier.discountPercentage.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTierInfo('Minimum Points', '${tier.minPoints}'),
              _buildTierInfo('Discount', '${tier.discountPercentage}%'),
              const SizedBox(height: 8),
              const Text(
                'Benefits:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...tier.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!isLowestTier)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTier(tier),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                  if (!isLowestTier) const SizedBox(width: 8),
                  if (!isHighestTier)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteTier(tier),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  if (isHighestTier || isLowestTier)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTier(tier),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _editTier(LoyaltyTier tier) {
    // TODO: Implement edit tier dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit tier: ${tier.name}')),
    );
  }

  void _deleteTier(LoyaltyTier tier) {
    // TODO: Implement delete tier confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete tier: ${tier.name}')),
    );
  }
}
