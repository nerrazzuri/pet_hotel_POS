import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';
import 'package:cat_hotel_pos/features/settings/domain/services/settings_service.dart';
import 'package:cat_hotel_pos/core/services/settings_dao.dart';

class NotificationSettingsTab extends ConsumerStatefulWidget {
  const NotificationSettingsTab({super.key});

  @override
  ConsumerState<NotificationSettingsTab> createState() => _NotificationSettingsTabState();
}

class _NotificationSettingsTabState extends ConsumerState<NotificationSettingsTab> {
  bool _enableNotifications = true;
  bool _enableSoundNotifications = true;
  bool _enableVibrationNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enableWhatsAppNotifications = false;
  bool _enablePushNotifications = true;
  bool _enableSmsNotifications = false;
  
  // Notification types
  bool _enableBookingNotifications = true;
  bool _enablePaymentNotifications = true;
  bool _enableInventoryNotifications = true;
  bool _enableStaffNotifications = true;
  bool _enableSystemNotifications = true;
  bool _enableMarketingNotifications = false;
  
  // Notification timing
  bool _enableQuietHours = false;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 8, minute: 0);
  
  // Email settings
  final _smtpServerController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _smtpUsernameController = TextEditingController();
  final _smtpPasswordController = TextEditingController();
  bool _enableSsl = true;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _smtpServerController.dispose();
    _smtpPortController.dispose();
    _smtpUsernameController.dispose();
    _smtpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final settings = await settingsService.getSettings();
      
      setState(() {
        _enableNotifications = settings.enableNotifications;
        _enableEmailNotifications = settings.enableEmailReceipts;
        _enableWhatsAppNotifications = settings.enableWhatsAppReceipts;
        _smtpServerController.text = settings.smtpServer;
        _smtpPortController.text = settings.smtpPort.toString();
        _smtpUsernameController.text = settings.smtpUsername;
        _smtpPasswordController.text = settings.smtpPassword;
        _enableSsl = settings.enableSsl;
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
        enableNotifications: _enableNotifications,
        enableEmailReceipts: _enableEmailNotifications,
        enableWhatsAppReceipts: _enableWhatsAppNotifications,
        smtpServer: _smtpServerController.text.trim(),
        smtpPort: int.tryParse(_smtpPortController.text) ?? 587,
        smtpUsername: _smtpUsernameController.text.trim(),
        smtpPassword: _smtpPasswordController.text.trim(),
        enableSsl: _enableSsl,
      );
      
      await settingsService.updateSettings(updatedSettings);
      
      setState(() => _hasChanges = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved successfully')),
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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietStartTime : _quietEndTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietStartTime = picked;
        } else {
          _quietEndTime = picked;
        }
        _markAsChanged();
      });
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
          // General Notification Settings
          _buildSectionHeader('General Notifications', Icons.notifications),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive all types of notifications'),
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
            
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _enablePushNotifications,
              onChanged: (value) {
                setState(() => _enablePushNotifications = value);
                _markAsChanged();
              },
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Notification Types
          _buildSectionHeader('Notification Types', Icons.category),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Booking Notifications'),
            subtitle: const Text('New bookings, cancellations, reminders'),
            value: _enableBookingNotifications,
            onChanged: (value) {
              setState(() => _enableBookingNotifications = value);
              _markAsChanged();
            },
          ),
          
          SwitchListTile(
            title: const Text('Payment Notifications'),
            subtitle: const Text('Payment confirmations, failed payments'),
            value: _enablePaymentNotifications,
            onChanged: (value) {
              setState(() => _enablePaymentNotifications = value);
              _markAsChanged();
            },
          ),
          
          SwitchListTile(
            title: const Text('Inventory Notifications'),
            subtitle: const Text('Low stock alerts, reorder reminders'),
            value: _enableInventoryNotifications,
            onChanged: (value) {
              setState(() => _enableInventoryNotifications = value);
              _markAsChanged();
            },
          ),
          
          SwitchListTile(
            title: const Text('Staff Notifications'),
            subtitle: const Text('Shift changes, schedule updates'),
            value: _enableStaffNotifications,
            onChanged: (value) {
              setState(() => _enableStaffNotifications = value);
              _markAsChanged();
            },
          ),
          
          SwitchListTile(
            title: const Text('System Notifications'),
            subtitle: const Text('Updates, maintenance, errors'),
            value: _enableSystemNotifications,
            onChanged: (value) {
              setState(() => _enableSystemNotifications = value);
              _markAsChanged();
            },
          ),
          
          SwitchListTile(
            title: const Text('Marketing Notifications'),
            subtitle: const Text('Promotions, special offers'),
            value: _enableMarketingNotifications,
            onChanged: (value) {
              setState(() => _enableMarketingNotifications = value);
              _markAsChanged();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Quiet Hours
          _buildSectionHeader('Quiet Hours', Icons.nightlight),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Quiet Hours'),
            subtitle: const Text('Reduce notifications during specified hours'),
            value: _enableQuietHours,
            onChanged: (value) {
              setState(() => _enableQuietHours = value);
              _markAsChanged();
            },
          ),
          
          if (_enableQuietHours) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_quietStartTime.format(context)),
                    trailing: ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: const Text('Set'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_quietEndTime.format(context)),
                    trailing: ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: const Text('Set'),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Email Settings
          _buildSectionHeader('Email Settings', Icons.email),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable Email Notifications'),
            subtitle: const Text('Send notifications via email'),
            value: _enableEmailNotifications,
            onChanged: (value) {
              setState(() => _enableEmailNotifications = value);
              _markAsChanged();
            },
          ),
          
          if (_enableEmailNotifications) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _smtpServerController,
              decoration: const InputDecoration(
                labelText: 'SMTP Server',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
              onChanged: (_) => _markAsChanged(),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _smtpPortController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Port',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Enable SSL'),
                    value: _enableSsl,
                    onChanged: (value) {
                      setState(() => _enableSsl = value);
                      _markAsChanged();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _smtpUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _smtpPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Test Email Configuration'),
              subtitle: const Text('Verify SMTP settings'),
              trailing: ElevatedButton(
                onPressed: () => _testEmailConfiguration(),
                child: const Text('Test'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // WhatsApp Settings
          _buildSectionHeader('WhatsApp Settings', Icons.phone),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable WhatsApp Notifications'),
            subtitle: const Text('Send notifications via WhatsApp'),
            value: _enableWhatsAppNotifications,
            onChanged: (value) {
              setState(() => _enableWhatsAppNotifications = value);
              _markAsChanged();
            },
          ),
          
          if (_enableWhatsAppNotifications) ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('WhatsApp Business Number'),
              subtitle: const Text('+60123456789'),
              trailing: ElevatedButton(
                onPressed: () => _configureWhatsApp(),
                child: const Text('Configure'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // SMS Settings
          _buildSectionHeader('SMS Settings', Icons.sms),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Enable SMS Notifications'),
            subtitle: const Text('Send notifications via SMS'),
            value: _enableSmsNotifications,
            onChanged: (value) {
              setState(() => _enableSmsNotifications = value);
              _markAsChanged();
            },
          ),
          
          if (_enableSmsNotifications) ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('SMS Gateway Configuration'),
              subtitle: const Text('Configure SMS provider settings'),
              trailing: ElevatedButton(
                onPressed: () => _configureSmsGateway(),
                child: const Text('Configure'),
              ),
            ),
          ],
          
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
                      'Save Notification Settings',
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

  Future<void> _testEmailConfiguration() async {
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
              Text('Testing email configuration...'),
            ],
          ),
        ),
      );
      
      final success = await settingsService.testSmtpConnection();
      
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email configuration test successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email configuration test failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing email configuration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _configureWhatsApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp Configuration'),
        content: const Text('WhatsApp Business API configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _configureSmsGateway() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Gateway Configuration'),
        content: const Text('SMS gateway configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
