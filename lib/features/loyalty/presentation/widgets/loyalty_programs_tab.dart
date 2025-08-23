import 'package:flutter/material.dart';
import '../../../../core/services/loyalty_dao.dart';
import '../../domain/entities/loyalty_program.dart';

class LoyaltyProgramsTab extends StatefulWidget {
  final LoyaltyDao loyaltyDao;

  const LoyaltyProgramsTab({super.key, required this.loyaltyDao});

  @override
  State<LoyaltyProgramsTab> createState() => _LoyaltyProgramsTabState();
}

class _LoyaltyProgramsTabState extends State<LoyaltyProgramsTab> {
  List<LoyaltyProgram> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() => _isLoading = true);
    try {
      final programs = await widget.loyaltyDao.getAllLoyaltyPrograms();
      setState(() {
        _programs = programs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading programs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_programs.isEmpty) {
      return const Center(
        child: Text('No loyalty programs found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _programs.length,
      itemBuilder: (context, index) {
        final program = _programs[index];
        return _buildProgramCard(program);
      },
    );
  }

  Widget _buildProgramCard(LoyaltyProgram program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: program.isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    program.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: program.isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(program.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Tiers', '${program.tiers.length} tiers'),
                _buildInfoRow('Points per RM', '${program.rules.pointsPerRinggit}'),
                _buildInfoRow('Points per night', '${program.rules.pointsPerNight}'),
                _buildInfoRow('Points per service', '${program.rules.pointsPerService}'),
                _buildInfoRow('Points expiry', '${program.rules.pointsExpiryMonths} months'),
                _buildInfoRow('Min redemption', 'RM ${program.rules.minimumRedemptionAmount}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editProgram(program),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleProgramStatus(program),
                        icon: Icon(
                          program.isActive ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(program.isActive ? 'Pause' : 'Activate'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _editProgram(LoyaltyProgram program) {
    // TODO: Implement edit program dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit program: ${program.name}')),
    );
  }

  void _toggleProgramStatus(LoyaltyProgram program) {
    // TODO: Implement toggle program status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          program.isActive ? 'Pausing program' : 'Activating program',
        ),
      ),
    );
  }
}
