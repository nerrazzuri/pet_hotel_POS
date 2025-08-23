import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/staff_service.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';
import 'package:fl_chart/fl_chart.dart';

class StaffAnalyticsTab extends ConsumerStatefulWidget {
  const StaffAnalyticsTab({super.key});

  @override
  ConsumerState<StaffAnalyticsTab> createState() => _StaffAnalyticsTabState();
}

class _StaffAnalyticsTabState extends ConsumerState<StaffAnalyticsTab> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final staffService = StaffService(StaffDao());
    
    return Column(
      children: [
        // Date Range Selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _exportReport(staffService),
                icon: const Icon(Icons.file_download),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Analytics Content
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: staffService.getStaffStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading analytics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              final stats = snapshot.data ?? {};
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metrics Cards
                    _buildKeyMetricsSection(stats),
                    
                    const SizedBox(height: 24),
                    
                    // Role Distribution Chart
                    _buildRoleDistributionChart(stats),
                    
                    const SizedBox(height: 24),
                    
                    // Shift Performance
                    _buildShiftPerformanceSection(staffService),
                    
                    const SizedBox(height: 24),
                    
                    // Payroll Summary
                    _buildPayrollSummarySection(staffService),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Staff',
                '${stats['totalStaff'] ?? 0}',
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Active Staff',
                '${stats['activeStaff'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Shifts',
                '${stats['totalShifts'] ?? 0}',
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Completion Rate',
                '${stats['completionRate']?.toStringAsFixed(1) ?? '0'}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDistributionChart(Map<String, dynamic> stats) {
    final roleDistribution = stats['roleDistribution'] as Map<String, int>? ?? {};
    
    if (roleDistribution.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final chartData = roleDistribution.entries.map((entry) {
      return PieChartSectionData(
        color: _getRoleColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Distribution',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: chartData,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: roleDistribution.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getRoleColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.key}: ${entry.value}'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'administrator':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'cashier':
        return Colors.green;
      case 'groomer':
        return Colors.orange;
      case 'housekeeper':
        return Colors.teal;
      case 'receptionist':
        return Colors.indigo;
      case 'veterinarian':
        return Colors.red;
      case 'assistant':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildShiftPerformanceSection(StaffService staffService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Performance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getShiftPerformanceData(staffService),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError || !snapshot.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No shift performance data available'),
                ),
              );
            }
            
            final performanceData = snapshot.data!;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Performance Metrics
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceMetric(
                            'Avg. Hours/Shift',
                            '${_calculateAverageHours(performanceData).toStringAsFixed(1)}h',
                            Icons.timer,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceMetric(
                            'Overtime Rate',
                            '${_calculateOvertimeRate(performanceData).toStringAsFixed(1)}%',
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceMetric(
                            'On-Time Rate',
                            '${_calculateOnTimeRate(performanceData).toStringAsFixed(1)}%',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Performance Chart
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}h');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  if (value.toInt() < days.length) {
                                    return Text(days[value.toInt()]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generatePerformanceSpots(performanceData),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getShiftPerformanceData(StaffService staffService) async {
    // Simulate performance data for the last 7 days
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      data.add({
        'date': date,
        'avgHours': 7.5 + (i % 3) * 0.5, // Simulate varying hours
        'overtimeHours': i % 2 == 0 ? 1.0 : 0.0, // Simulate overtime
        'onTime': i % 3 != 0, // Simulate on-time performance
      });
    }
    
    return data;
  }

  double _calculateAverageHours(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    final totalHours = data.fold<double>(0.0, (sum, item) => sum + (item['avgHours'] as double));
    return totalHours / data.length;
  }

  double _calculateOvertimeRate(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    final overtimeDays = data.where((item) => (item['overtimeHours'] as double) > 0).length;
    return (overtimeDays / data.length) * 100;
  }

  double _calculateOnTimeRate(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    final onTimeDays = data.where((item) => item['onTime'] as bool).length;
    return (onTimeDays / data.length) * 100;
  }

  List<FlSpot> _generatePerformanceSpots(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['avgHours'] as double);
    }).toList();
  }

  Widget _buildPerformanceMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPayrollSummarySection(StaffService staffService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payroll Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<double>(
          future: staffService.calculatePayroll(_startDate, _endDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final totalPayroll = snapshot.data ?? 0.0;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Payroll',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'RM ${totalPayroll.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              Text(
                                '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Payroll Breakdown
                    Row(
                      children: [
                        Expanded(
                          child: _buildPayrollBreakdown(
                            'Regular Hours',
                            'RM ${(totalPayroll * 0.8).toStringAsFixed(2)}',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPayrollBreakdown(
                            'Overtime',
                            'RM ${(totalPayroll * 0.2).toStringAsFixed(2)}',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPayrollBreakdown(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _exportReport(StaffService staffService) {
    // TODO: Implement report export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report export - Coming Soon')),
    );
  }
}
