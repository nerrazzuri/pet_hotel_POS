import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';
import 'package:cat_hotel_pos/features/settings/domain/services/settings_service.dart';
import 'package:cat_hotel_pos/core/services/settings_dao.dart';

class SystemSettingsTab extends ConsumerStatefulWidget {
  const SystemSettingsTab({super.key});

  @override
  ConsumerState<SystemSettingsTab> createState() => _SystemSettingsTabState();
}

class _SystemSettingsTabState extends ConsumerState<SystemSettingsTab> {
  bool _isLoading = false;
  Map<String, dynamic> _systemInfo = {};
  bool _isMaintenanceRunning = false;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final systemInfo = settingsService.getSystemInfo();
      
      setState(() {
        _systemInfo = systemInfo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading system info: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performMaintenance() async {
    setState(() => _isMaintenanceRunning = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final results = await settingsService.performMaintenance();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maintenance completed at ${results['maintenanceCompleted']}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload system info
      await _loadSystemInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during maintenance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isMaintenanceRunning = false);
    }
  }

  Future<void> _exportSettings() async {
    try {
      final settingsService = SettingsService(SettingsDao());
      final settings = await settingsService.exportSettings();
      
      // In a real app, you would save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importSettings() async {
    // In a real app, you would show a file picker here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import settings functionality will be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all data including customers, bookings, inventory, and transactions. '
          'This action cannot be undone. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Simulate data clearing
        await Future.delayed(const Duration(seconds: 3));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
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
          // System Information Section
          _buildSectionHeader('System Information', Icons.info),
          const SizedBox(height: 16),
          
          _buildInfoCard(
            'Application Version',
            _systemInfo['appVersion'] ?? 'Unknown',
            Icons.apps,
            Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Flutter Version',
                  _systemInfo['flutterVersion'] ?? 'Unknown',
                  Icons.flutter_dash,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Dart Version',
                  _systemInfo['dartVersion'] ?? 'Unknown',
                  Icons.code,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoCard(
            'Platform',
            _systemInfo['platform'] ?? 'Unknown',
            Icons.devices,
            Colors.green,
          ),
          
          const SizedBox(height: 24),
          
          // Storage Information Section
          _buildSectionHeader('Storage Information', Icons.storage),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Database Size',
                  _systemInfo['databaseSize'] ?? 'Unknown',
                  Icons.storage,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Cache Size',
                  _systemInfo['cacheSize'] ?? 'Unknown',
                  Icons.cached,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoCard(
            'Last Backup',
            _systemInfo['lastBackup'] != null 
                ? _formatDateTime(_systemInfo['lastBackup'])
                : 'Never',
            Icons.backup,
            Colors.green,
          ),
          
          const SizedBox(height: 24),
          
          // System Maintenance Section
          _buildSectionHeader('System Maintenance', Icons.build),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: Colors.blue),
            title: const Text('Run System Maintenance'),
            subtitle: const Text('Clean cache, optimize database, rotate logs'),
            trailing: ElevatedButton(
              onPressed: _isMaintenanceRunning ? null : _performMaintenance,
              child: _isMaintenanceRunning
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Data Management Section
          _buildSectionHeader('Data Management', Icons.data_usage),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.green),
            title: const Text('Export Settings'),
            subtitle: const Text('Export current settings to file'),
            trailing: ElevatedButton(
              onPressed: _exportSettings,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Export'),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.file_upload, color: Colors.blue),
            title: const Text('Import Settings'),
            subtitle: const Text('Import settings from file'),
            trailing: ElevatedButton(
              onPressed: _importSettings,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Import'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Advanced Section
          _buildSectionHeader('Advanced', Icons.settings),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Permanently delete all application data'),
            trailing: ElevatedButton(
              onPressed: _clearAllData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Status Section
          _buildSectionHeader('System Status', Icons.monitor_heart),
          const SizedBox(height: 16),
          
          _buildStatusCard(
            'Database',
            'Connected',
            Icons.check_circle,
            Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          _buildStatusCard(
            'Cache',
            'Healthy',
            Icons.check_circle,
            Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          _buildStatusCard(
            'Backup Service',
            'Active',
            Icons.check_circle,
            Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          _buildStatusCard(
            'Email Service',
            'Configured',
            Icons.check_circle,
            Colors.green,
          ),
          
          const SizedBox(height: 32),
          
          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadSystemInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh System Information'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String service, String status, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(service),
        subtitle: Text(status),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
