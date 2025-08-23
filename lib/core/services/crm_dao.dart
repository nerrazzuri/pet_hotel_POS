import 'dart:math';
import '../../features/crm/domain/entities/campaign.dart';
import '../../features/crm/domain/entities/communication_template.dart';
import '../../features/crm/domain/entities/automated_reminder.dart';

class CrmDao {
  static final CrmDao _instance = CrmDao._internal();
  factory CrmDao() => _instance;
  CrmDao._internal();

  final List<Campaign> _campaigns = [];
  final List<CommunicationTemplate> _templates = [];
  final List<AutomatedReminder> _reminders = [];

  Future<void> init() async {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample communication templates
    _templates.addAll([
      CommunicationTemplate(
        id: 'template_001',
        name: 'Vaccination Reminder',
        description: 'Reminder for upcoming vaccination expiry',
        type: TemplateType.whatsapp,
        category: TemplateCategory.vaccination,
        subject: 'Vaccination Reminder',
        content: 'Hi {{customerName}}, your pet {{petName}}\'s vaccination expires on {{expiryDate}}. Please schedule an appointment soon!',
        variables: {
          'customerName': 'Customer Name',
          'petName': 'Pet Name',
          'expiryDate': 'Expiry Date',
        },
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
      ),
      CommunicationTemplate(
        id: 'template_002',
        name: 'Booking Confirmation',
        description: 'Confirmation for new bookings',
        type: TemplateType.email,
        category: TemplateCategory.booking,
        subject: 'Booking Confirmation - {{bookingId}}',
        content: 'Dear {{customerName}}, your booking for {{petName}} has been confirmed for {{checkInDate}} to {{checkOutDate}}. Thank you for choosing our cat hotel!',
        variables: {
          'customerName': 'Customer Name',
          'petName': 'Pet Name',
          'bookingId': 'Booking ID',
          'checkInDate': 'Check-in Date',
          'checkOutDate': 'Check-out Date',
        },
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
      ),
      CommunicationTemplate(
        id: 'template_003',
        name: 'Loyalty Points Update',
        description: 'Update on loyalty points earned',
        type: TemplateType.sms,
        category: TemplateCategory.loyalty,
        subject: 'Loyalty Points Update',
        content: 'Hi {{customerName}}, you earned {{points}} points from your recent {{service}}. Your total points: {{totalPoints}}. Current tier: {{tier}}',
        variables: {
          'customerName': 'Customer Name',
          'points': 'Points Earned',
          'service': 'Service Type',
          'totalPoints': 'Total Points',
          'tier': 'Current Tier',
        },
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
      ),
    ]);

    // Sample campaigns
    _campaigns.addAll([
      Campaign(
        id: 'campaign_001',
        name: 'Summer Special Promotion',
        description: 'Special summer rates for boarding services',
        type: CampaignType.email,
        status: CampaignStatus.active,
        target: CampaignTarget.allCustomers,
        subject: 'Summer Special - 20% Off Boarding!',
        content: 'Book your cat\'s summer vacation with us and enjoy 20% off all boarding services!',
        templateId: 'template_002',
        targetCustomerIds: ['customer_001', 'customer_002', 'customer_003'],
        targetCriteria: {'loyaltyTier': 'silver'},
        scheduledAt: DateTime.now().subtract(const Duration(days: 5)),
        sentAt: DateTime.now().subtract(const Duration(days: 5)),
        totalRecipients: 150,
        sentCount: 150,
        openedCount: 45,
        clickedCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'manager',
      ),
      Campaign(
        id: 'campaign_002',
        name: 'Vaccination Reminder Campaign',
        description: 'Remind customers about expiring vaccinations',
        type: CampaignType.whatsapp,
        status: CampaignStatus.scheduled,
        target: CampaignTarget.expiringVaccinations,
        subject: 'Vaccination Reminder',
        content: 'Your pet\'s vaccination is expiring soon. Please schedule an appointment.',
        templateId: 'template_001',
        targetCustomerIds: [],
        targetCriteria: {'vaccinationExpiryDays': 30},
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
        sentAt: null,
        totalRecipients: 25,
        sentCount: 0,
        openedCount: 0,
        clickedCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'admin',
      ),
    ]);

    // Sample automated reminders
    _reminders.addAll([
      AutomatedReminder(
        id: 'reminder_001',
        customerId: 'customer_001',
        petId: 'pet_001',
        type: ReminderType.vaccinationExpiry,
        status: ReminderStatus.pending,
        channel: ReminderChannel.whatsapp,
        subject: 'Vaccination Reminder',
        message: 'Hi Sarah, Whiskers\' vaccination expires in 2 weeks. Please schedule an appointment.',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        sentAt: null,
        retryCount: 0,
        errorMessage: null,
        metadata: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AutomatedReminder(
        id: 'reminder_002',
        customerId: 'customer_002',
        petId: 'pet_002',
        type: ReminderType.upcomingBooking,
        status: ReminderStatus.pending,
        channel: ReminderChannel.email,
        subject: 'Upcoming Booking Reminder',
        message: 'Hi John, your booking for Fluffy is tomorrow. Please prepare for check-in.',
        scheduledAt: DateTime.now().add(const Duration(hours: 12)),
        sentAt: null,
        retryCount: 0,
        errorMessage: null,
        metadata: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AutomatedReminder(
        id: 'reminder_003',
        customerId: 'customer_001',
        petId: null,
        type: ReminderType.loyaltyPointsExpiry,
        status: ReminderStatus.pending,
        channel: ReminderChannel.sms,
        subject: 'Loyalty Points Expiry',
        message: 'Hi Sarah, 500 of your loyalty points will expire in 30 days. Use them soon!',
        scheduledAt: DateTime.now().add(const Duration(days: 7)),
        sentAt: null,
        retryCount: 0,
        errorMessage: null,
        metadata: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  // Campaign methods
  Future<List<Campaign>> getAllCampaigns() async {
    return List.unmodifiable(_campaigns);
  }

  Future<Campaign?> getCampaignById(String id) async {
    try {
      return _campaigns.firstWhere((campaign) => campaign.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status) async {
    return _campaigns
        .where((campaign) => campaign.status == status)
        .toList();
  }

  Future<List<Campaign>> getCampaignsByType(CampaignType type) async {
    return _campaigns
        .where((campaign) => campaign.type == type)
        .toList();
  }

  Future<Campaign> createCampaign(Campaign campaign) async {
    final newCampaign = campaign.copyWith(
      id: 'campaign_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _campaigns.add(newCampaign);
    return newCampaign;
  }

  Future<Campaign> updateCampaign(Campaign campaign) async {
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      final updatedCampaign = campaign.copyWith(updatedAt: DateTime.now());
      _campaigns[index] = updatedCampaign;
      return updatedCampaign;
    }
    throw Exception('Campaign not found');
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((campaign) => campaign.id == id);
  }

  // Template methods
  Future<List<CommunicationTemplate>> getAllTemplates() async {
    return List.unmodifiable(_templates);
  }

  Future<CommunicationTemplate?> getTemplateById(String id) async {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CommunicationTemplate>> getTemplatesByType(TemplateType type) async {
    return _templates
        .where((template) => template.type == type)
        .toList();
  }

  Future<List<CommunicationTemplate>> getTemplatesByCategory(TemplateCategory category) async {
    return _templates
        .where((template) => template.category == category)
        .toList();
  }

  Future<CommunicationTemplate> createTemplate(CommunicationTemplate template) async {
    final newTemplate = template.copyWith(
      id: 'template_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _templates.add(newTemplate);
    return newTemplate;
  }

  Future<CommunicationTemplate> updateTemplate(CommunicationTemplate template) async {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      final updatedTemplate = template.copyWith(updatedAt: DateTime.now());
      _templates[index] = updatedTemplate;
      return updatedTemplate;
    }
    throw Exception('Template not found');
  }

  Future<void> deleteTemplate(String id) async {
    _templates.removeWhere((template) => template.id == id);
  }

  // Reminder methods
  Future<List<AutomatedReminder>> getAllReminders() async {
    return List.unmodifiable(_reminders);
  }

  Future<AutomatedReminder?> getReminderById(String id) async {
    try {
      return _reminders.firstWhere((reminder) => reminder.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<AutomatedReminder>> getRemindersByCustomerId(String customerId) async {
    return _reminders
        .where((reminder) => reminder.customerId == customerId)
        .toList();
  }

  Future<List<AutomatedReminder>> getRemindersByType(ReminderType type) async {
    return _reminders
        .where((reminder) => reminder.type == type)
        .toList();
  }

  Future<List<AutomatedReminder>> getRemindersByStatus(ReminderStatus status) async {
    return _reminders
        .where((reminder) => reminder.status == status)
        .toList();
  }

  Future<List<AutomatedReminder>> getPendingReminders() async {
    return _reminders
        .where((reminder) => 
            reminder.status == ReminderStatus.pending &&
            reminder.scheduledAt.isBefore(DateTime.now()))
        .toList();
  }

  Future<AutomatedReminder> createReminder(AutomatedReminder reminder) async {
    final newReminder = reminder.copyWith(
      id: 'reminder_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _reminders.add(newReminder);
    return newReminder;
  }

  Future<AutomatedReminder> updateReminder(AutomatedReminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());
      _reminders[index] = updatedReminder;
      return updatedReminder;
    }
    throw Exception('Reminder not found');
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((reminder) => reminder.id == id);
  }

  // Helper methods
  Future<Map<String, int>> getCampaignStats() async {
    final totalCampaigns = _campaigns.length;
    final activeCampaigns = _campaigns
        .where((c) => c.status == CampaignStatus.active)
        .length;
    final scheduledCampaigns = _campaigns
        .where((c) => c.status == CampaignStatus.scheduled)
        .length;
    final completedCampaigns = _campaigns
        .where((c) => c.status == CampaignStatus.completed)
        .length;

    return {
      'total': totalCampaigns,
      'active': activeCampaigns,
      'scheduled': scheduledCampaigns,
      'completed': completedCampaigns,
    };
  }

  Future<Map<String, int>> getReminderStats() async {
    final totalReminders = _reminders.length;
    final pendingReminders = _reminders
        .where((r) => r.status == ReminderStatus.pending)
        .length;
    final sentReminders = _reminders
        .where((r) => r.status == ReminderStatus.sent)
        .length;
    final failedReminders = _reminders
        .where((r) => r.status == ReminderStatus.failed)
        .length;

    return {
      'total': totalReminders,
      'pending': pendingReminders,
      'sent': sentReminders,
      'failed': failedReminders,
    };
  }
}
