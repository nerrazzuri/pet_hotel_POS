import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';
import 'package:cat_hotel_pos/features/settings/domain/services/settings_service.dart';
import 'package:cat_hotel_pos/core/services/settings_dao.dart';

class GeneralSettingsTab extends ConsumerStatefulWidget {
  const GeneralSettingsTab({super.key});

  @override
  ConsumerState<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}

class _GeneralSettingsTabState extends ConsumerState<GeneralSettingsTab> {
  String _selectedLanguage = 'en';
  bool _enableBiometricAuth = false;
  bool _enableAutoBackup = true;
  String _selectedBackupFrequency = 'daily';
  bool _enableNotifications = true;
  bool _enableSoundNotifications = true;
  bool _enableVibrationNotifications = true;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final settings = await settingsService.getSettings();
      
      setState(() {
        _selectedLanguage = settings.language;
        _enableBiometricAuth = settings.enableBiometricAuth;
        _enableAutoBackup = settings.enableAutoBackup;
        _selectedBackupFrequency = settings.backupFrequency;
        _enableNotifications = settings.enableNotifications;
        _enableSoundNotifications = true; // Default values
        _enableVibrationNotifications = true; // Default values
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final currentSettings = await settingsService.getSettings();
      
      final updatedSettings = currentSettings.copyWith(
        language: _selectedLanguage,
        enableBiometricAuth: _enableBiometricAuth,
        enableAutoBackup: _enableAutoBackup,
        backupFrequency: _selectedBackupFrequency,
        enableNotifications: _enableNotifications,
      );
      
      await settingsService.updateSettings(updatedSettings);
      
      setState(() => _hasChanges = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('General settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
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
          // Language & Localization Section
          _buildSectionHeader('Language & Localization', Icons.language),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Application Language',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.translate),
            ),
            items: [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ms', child: Text('Bahasa Melayu')),
              DropdownMenuItem(value: 'zh', child: Text('中文')),
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
                _markAsChanged();
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // Security Settings Section
          _buildSectionHeader('Security Settings', Icons.security),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID for login'),
            value: _enableBiometricAuth,
            onChanged: (value) {
              setState(() => _enableBiometricAuth = value);
              _markAsChanged();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Backup Settings Section
          _buildSectionHeader('Backup & Sync', Icons.backup),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Auto Backup'),
            subtitle: const Text('Automatically backup data to cloud'),
            value: _enableAutoBackup,
            onChanged: (value) {
              setState(() => _enableAutoBackup = value);
              _markAsChanged();
            },
          ),
          
          if (_enableAutoBackup) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBackupFrequency,
              decoration: const InputDecoration(
                labelText: 'Backup Frequency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              items: [
                DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedBackupFrequency = value);
                  _markAsChanged();
                }
              },
            ),
            
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.blue),
              title: const Text('Manual Backup'),
              subtitle: const Text('Create backup now'),
              trailing: ElevatedButton(
                onPressed: () => _performManualBackup(),
                child: const Text('Backup Now'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Notification Settings Section
          _buildSectionHeader('Notification Settings', Icons.notifications),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() => _enableNotifications = value);
              _markAsChanged();
            },
          ),
          
          if (_enableNotifications) ...[
            SwitchListTile(
              title: const Text('Sound Notifications'),
              subtitle: const Text('Play sound for notifications'),
              value: _enableSoundNotifications,
              onChanged: (value) {
                setState(() => _enableSoundNotifications = value);
                _markAsChanged();
              },
            ),
            
            SwitchListTile(
              title: const Text('Vibration Notifications'),
              subtitle: const Text('Vibrate for notifications'),
              value: _enableVibrationNotifications,
              onChanged: (value) {
                setState(() => _enableVibrationNotifications = value);
                _markAsChanged();
              },
            ),
            
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification'),
              trailing: ElevatedButton(
                onPressed: () => _testNotification(),
                child: const Text('Test'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Data Management Section
          _buildSectionHeader('Data Management', Icons.storage),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: ElevatedButton(
              onPressed: () => _clearCache(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Restore default settings'),
            trailing: ElevatedButton(
              onPressed: () => _resetToDefaults(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reset'),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasChanges ? _saveSettings : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save General Settings',
                      style: TextStyle(fontSize: 16),
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

  Future<void> _performManualBackup() async {
    try {
      final settingsService = SettingsService(SettingsDao());
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating backup...'),
            ],
          ),
        ),
      );
      
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully')),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating backup: $e')),
      );
    }
  }

  void _testNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache? This will free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // Simulate cache clearing
        await Future.delayed(const Duration(seconds: 1));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('Are you sure you want to reset all settings to default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final settingsService = SettingsService(SettingsDao());
        await settingsService.resetToDefaults();
        
        // Reload settings
        await _loadSettings();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting settings: $e')),
        );
      }
    }
  }
}
