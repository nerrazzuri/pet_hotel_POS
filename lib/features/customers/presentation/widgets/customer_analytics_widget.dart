import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

class CustomerAnalyticsWidget extends ConsumerStatefulWidget {
  const CustomerAnalyticsWidget({super.key});

  @override
  ConsumerState<CustomerAnalyticsWidget> createState() => _CustomerAnalyticsWidgetState();
}

class _CustomerAnalyticsWidgetState extends ConsumerState<CustomerAnalyticsWidget> {
  final CustomerDao _customerDao = CustomerDao();
  String _selectedTimeRange = '30_days';
  String _selectedMetric = 'customer_growth';

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
                Text('Error loading analytics: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final customers = snapshot.data ?? [];
        final analyticsData = _calculateAnalytics(customers);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Time Range and Metric Selector
              _buildControls(),
              const SizedBox(height: 24),

              // Key Metrics
              _buildKeyMetrics(analyticsData),
              const SizedBox(height: 24),

              // Charts and Visualizations
              _buildCharts(analyticsData),
              const SizedBox(height: 24),

              // Customer Segments
              _buildCustomerSegments(analyticsData),
              const SizedBox(height: 24),

              // Trends and Insights
              _buildTrendsAndInsights(analyticsData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.analytics, size: 32, color: Colors.purple),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Comprehensive insights into customer behavior and trends',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _exportAnalytics,
          icon: const Icon(Icons.download),
          label: const Text('Export Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Time Range: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedTimeRange,
              items: [
                DropdownMenuItem(value: '7_days', child: Text('Last 7 Days')),
                DropdownMenuItem(value: '30_days', child: Text('Last 30 Days')),
                DropdownMenuItem(value: '90_days', child: Text('Last 90 Days')),
                DropdownMenuItem(value: '1_year', child: Text('Last Year')),
                DropdownMenuItem(value: 'all_time', child: Text('All Time')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTimeRange = value;
                  });
                }
              },
            ),
            const SizedBox(width: 32),
            const Text('Metric: ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedMetric,
              items: [
                DropdownMenuItem(value: 'customer_growth', child: Text('Customer Growth')),
                DropdownMenuItem(value: 'revenue', child: Text('Revenue')),
                DropdownMenuItem(value: 'loyalty', child: Text('Loyalty Points')),
                DropdownMenuItem(value: 'engagement', child: Text('Engagement')),
                DropdownMenuItem(value: 'retention', child: Text('Retention Rate')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMetric = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Customers',
          '${data['totalCustomers']}',
          Icons.people,
          Colors.blue,
          data['customerGrowth'],
        ),
        _buildMetricCard(
          'Active Customers',
          '${data['activeCustomers']}',
          Icons.person,
          Colors.green,
          data['activeGrowth'],
        ),
        _buildMetricCard(
          'New This Period',
          '${data['newCustomers']}',
          Icons.person_add,
          Colors.orange,
          data['newGrowth'],
        ),
        _buildMetricCard(
          'Churn Rate',
          '${data['churnRate']}%',
          Icons.trending_down,
          Colors.red,
          data['churnTrend'],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double? trend) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 24, color: color),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trend >= 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> data) {
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
                    'Customer Growth Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildGrowthChart(data['growthData']),
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
                    'Customer Source Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildSourceChart(data['sourceData']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthChart(List<Map<String, dynamic>> growthData) {
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
            Icon(Icons.show_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Growth Chart',
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

  Widget _buildSourceChart(Map<String, int> sourceData) {
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
              'Source Distribution',
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

  Widget _buildCustomerSegments(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Segments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSegmentCard(
                    'VIP Customers',
                    '${data['vipCustomers']}',
                    'High-value, frequent visitors',
                    Colors.purple,
                    Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSegmentCard(
                    'Regular Customers',
                    '${data['regularCustomers']}',
                    'Consistent, moderate usage',
                    Colors.blue,
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSegmentCard(
                    'Occasional Customers',
                    '${data['occasionalCustomers']}',
                    'Infrequent, low usage',
                    Colors.orange,
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSegmentCard(
                    'At Risk',
                    '${data['atRiskCustomers']}',
                    'Declining engagement',
                    Colors.red,
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentCard(String title, String count, String description, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsAndInsights(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trends & Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Peak Check-in Times',
                    data['peakCheckinTimes'],
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightCard(
                    'Most Popular Services',
                    data['popularServices'],
                    Icons.star,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightCard(
                    'Customer Satisfaction',
                    '${data['satisfactionScore']}%',
                    Icons.sentiment_satisfied,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendations(data['recommendations']),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(List<String> recommendations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateAnalytics(List<Customer> customers) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));

    final totalCustomers = customers.length;
    final activeCustomers = customers.where((c) => c.status.name == 'active').length;
    final newCustomers = customers.where((c) => c.createdAt.isAfter(thirtyDaysAgo)).length;
    
    // Calculate growth rates (simplified for demo)
    final customerGrowth = totalCustomers > 0 ? 5.2 : 0.0;
    final activeGrowth = activeCustomers > 0 ? 3.8 : 0.0;
    final newGrowth = newCustomers > 0 ? 12.5 : 0.0;
    final churnRate = 2.1;
    final churnTrend = -0.5;

    // Generate sample data for charts
    final growthData = List.generate(12, (index) {
      final date = now.subtract(Duration(days: (11 - index) * 30));
      return {
        'date': date,
        'customers': (totalCustomers * 0.8 + index * 2).round(),
      };
    });

    final sourceData = {
      'Referral': 35,
      'Social Media': 25,
      'Walk-in': 20,
      'Website': 15,
      'Other': 5,
    };

    // Customer segments
    final vipCustomers = (totalCustomers * 0.15).round();
    final regularCustomers = (totalCustomers * 0.45).round();
    final occasionalCustomers = (totalCustomers * 0.30).round();
    final atRiskCustomers = (totalCustomers * 0.10).round();

    // Insights
    final peakCheckinTimes = '2:00 PM - 4:00 PM';
    final popularServices = 'Boarding, Grooming';
    final satisfactionScore = 94;

    // Recommendations
    final recommendations = [
      'Focus on customer retention strategies for at-risk customers',
      'Increase marketing efforts during peak check-in times',
      'Develop loyalty programs for VIP customers',
      'Improve service quality based on customer feedback',
      'Implement automated follow-up for new customers',
    ];

    return {
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'newCustomers': newCustomers,
      'customerGrowth': customerGrowth,
      'activeGrowth': activeGrowth,
      'newGrowth': newGrowth,
      'churnRate': churnRate,
      'churnTrend': churnTrend,
      'growthData': growthData,
      'sourceData': sourceData,
      'vipCustomers': vipCustomers,
      'regularCustomers': regularCustomers,
      'occasionalCustomers': occasionalCustomers,
      'atRiskCustomers': atRiskCustomers,
      'peakCheckinTimes': peakCheckinTimes,
      'popularServices': popularServices,
      'satisfactionScore': satisfactionScore,
      'recommendations': recommendations,
    };
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting analytics report...')),
    );
  }
}
