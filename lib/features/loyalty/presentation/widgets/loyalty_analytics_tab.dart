import 'package:flutter/material.dart';
import '../../../../core/services/loyalty_dao.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_transaction.dart';

class LoyaltyAnalyticsTab extends StatefulWidget {
  final LoyaltyDao loyaltyDao;

  const LoyaltyAnalyticsTab({super.key, required this.loyaltyDao});

  @override
  State<LoyaltyAnalyticsTab> createState() => _LoyaltyAnalyticsTabState();
}

class _LoyaltyAnalyticsTabState extends State<LoyaltyAnalyticsTab> {
  LoyaltyProgram? _activeProgram;
  List<LoyaltyTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final program = await widget.loyaltyDao.getActiveLoyaltyProgram();
      final transactions = await widget.loyaltyDao.getAllLoyaltyTransactions();
      setState(() {
        _activeProgram = program;
        _transactions = transactions;
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

    if (_activeProgram == null) {
      return const Center(
        child: Text('No active loyalty program found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildTierDistribution(),
          const SizedBox(height: 24),
          _buildTransactionTrends(),
          const SizedBox(height: 24),
          _buildTopCustomers(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalPoints = _transactions
        .where((tx) => tx.type == LoyaltyTransactionType.earned)
        .fold(0, (sum, tx) => sum + tx.points);
    
    final redeemedPoints = _transactions
        .where((tx) => tx.type == LoyaltyTransactionType.redeemed)
        .fold(0, (sum, tx) => sum + tx.points.abs());
    
    final activeCustomers = _transactions
        .map((tx) => tx.customerId)
        .toSet()
        .length;

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Points Issued',
          '$totalPoints',
          Icons.add_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Points Redeemed',
          '$redeemedPoints',
          Icons.remove_circle,
          Colors.red,
        ),
        _buildStatCard(
          'Active Customers',
          '$activeCustomers',
          Icons.people,
          Colors.blue,
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

  Widget _buildTierDistribution() {
    final tierStats = <String, int>{};
    for (final tier in _activeProgram!.tiers) {
      tierStats[tier.name] = 0;
    }

    // Count customers in each tier (simplified - in real app would check actual customer tiers)
    for (final customerId in _transactions.map((tx) => tx.customerId).toSet()) {
      final customerPoints = _transactions
          .where((tx) => tx.customerId == customerId)
          .fold(0, (sum, tx) => sum + tx.points);
      
      for (final tier in _activeProgram!.tiers) {
        if (customerPoints >= tier.minPoints) {
          tierStats[tier.name] = (tierStats[tier.name] ?? 0) + 1;
          break; // Customer can only be in one tier
        }
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tier Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...tierStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / tierStats.values.reduce((a, b) => a + b),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTierColor(_activeProgram!.tiers
                            .firstWhere((t) => t.name == entry.key)
                            .color),
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

  Widget _buildTransactionTrends() {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    
    final dailyEarnings = <DateTime, int>{};
    final dailyRedemptions = <DateTime, int>{};
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      dailyEarnings[date] = 0;
      dailyRedemptions[date] = 0;
    }

    for (final tx in _transactions) {
      if (tx.createdAt.isAfter(last30Days)) {
        final date = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
        if (tx.type == LoyaltyTransactionType.earned) {
          dailyEarnings[date] = (dailyEarnings[date] ?? 0) + tx.points;
        } else if (tx.type == LoyaltyTransactionType.redeemed) {
          dailyRedemptions[date] = (dailyRedemptions[date] ?? 0) + tx.points.abs();
        }
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Trends (Last 30 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTrendChart(
                      'Points Earned',
                      dailyEarnings.values.toList(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTrendChart(
                      'Points Redeemed',
                      dailyRedemptions.values.toList(),
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(String title, List<int> data, Color color) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final normalizedData = data.map((value) => value / maxValue).toList();

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: TrendChartPainter(normalizedData, color),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers() {
    final customerPoints = <String, int>{};
    
    for (final tx in _transactions) {
      customerPoints[tx.customerId] = (customerPoints[tx.customerId] ?? 0) + tx.points;
    }

    final sortedCustomers = customerPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCustomers = sortedCustomers.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Customers by Points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topCustomers.asMap().entries.map((entry) {
              final index = entry.key;
              final customer = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Customer ${customer.key}'),
                trailing: Text(
                  '${customer.value} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }),
          ],
        ),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }
}

class TrendChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  TrendChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width / (data.length - 1);
    final height = size.height;

    for (int i = 0; i < data.length; i++) {
      final x = i * width;
      final y = height - (data[i] * height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
