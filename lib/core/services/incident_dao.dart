import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';

class IncidentDao {
  static final IncidentDao _instance = IncidentDao._internal();
  factory IncidentDao() => _instance;
  IncidentDao._internal();

  final List<Incident> _incidents = [];

  void _initialize() {
    if (_incidents.isEmpty) {
      final now = DateTime.now();
      
      _incidents.addAll([
        Incident(
          id: 'i1',
          customerId: 'cust1',
          customerName: 'John Smith',
          petId: 'pet1',
          petName: 'Whiskers',
          type: IncidentType.medical,
          severity: IncidentSeverity.minor,
          status: IncidentStatus.resolved,
          title: 'Minor Scratch on Paw',
          description: 'Whiskers got a small scratch on his front paw while playing in the common area.',
          reportedDate: now.subtract(const Duration(days: 5)),
          reportedBy: 'Staff Member',
          occurredDate: now.subtract(const Duration(days: 5)),
          resolvedDate: now.subtract(const Duration(days: 4)),
          location: 'Common Play Area',
          witnesses: 'Sarah (Staff), Mike (Staff)',
          actionsTaken: 'Cleaned wound, applied antiseptic, monitored for 24 hours',
          followUpRequired: 'Check healing progress in 3 days',
          notes: 'Pet was calm during treatment. No signs of infection.',
          requiresVeterinarian: false,
          requiresCustomerNotification: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 4)),
        ),
        Incident(
          id: 'i2',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          petId: 'pet2',
          petName: 'Buddy',
          type: IncidentType.behavioral,
          severity: IncidentSeverity.moderate,
          status: IncidentStatus.investigating,
          title: 'Aggressive Behavior Toward Other Pets',
          description: 'Buddy has been showing aggressive behavior toward other pets during group activities.',
          reportedDate: now.subtract(const Duration(days: 2)),
          reportedBy: 'Staff Member',
          occurredDate: now.subtract(const Duration(days: 3)),
          location: 'Group Play Area',
          witnesses: 'All staff members present',
          actionsTaken: 'Separated from group, increased individual attention, behavior monitoring',
          followUpRequired: 'Daily behavior assessment, consider professional trainer consultation',
          notes: 'May be due to stress from new environment. Monitoring closely.',
          requiresVeterinarian: false,
          requiresCustomerNotification: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        Incident(
          id: 'i3',
          customerId: 'cust3',
          customerName: 'Mike Davis',
          petId: 'pet3',
          petName: 'Luna',
          type: IncidentType.medical,
          severity: IncidentSeverity.major,
          status: IncidentStatus.escalated,
          title: 'Suspected Allergic Reaction',
          description: 'Luna developed hives and swelling after eating the provided food.',
          reportedDate: now.subtract(const Duration(days: 1)),
          reportedBy: 'Staff Member',
          occurredDate: now.subtract(const Duration(days: 1)),
          location: 'Feeding Area',
          witnesses: 'Staff Member, Other pets in area',
          actionsTaken: 'Immediate food removal, antihistamine administration, veterinarian consultation',
          followUpRequired: 'Veterinarian follow-up, allergy testing, special diet plan',
          notes: 'Customer notified immediately. Pet responding well to treatment.',
          requiresVeterinarian: true,
          requiresCustomerNotification: true,
          blocksCheckIn: true,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Incident(
          id: 'i4',
          customerId: 'cust1',
          customerName: 'John Smith',
          petId: 'pet1',
          petName: 'Whiskers',
          type: IncidentType.accident,
          severity: IncidentSeverity.minor,
          status: IncidentStatus.closed,
          title: 'Water Bowl Spillage',
          description: 'Whiskers knocked over his water bowl, creating a wet area on the floor.',
          reportedDate: now.subtract(const Duration(days: 10)),
          reportedBy: 'Staff Member',
          occurredDate: now.subtract(const Duration(days: 10)),
          location: 'Whiskers\' Room',
          witnesses: 'Staff Member',
          actionsTaken: 'Cleaned up water, secured water bowl, provided fresh water',
          followUpRequired: 'None',
          notes: 'Minor incident, no injuries. Water bowl secured to prevent future spills.',
          requiresVeterinarian: false,
          requiresCustomerNotification: false,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        Incident(
          id: 'i5',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          petId: 'pet2',
          petName: 'Buddy',
          type: IncidentType.escape,
          severity: IncidentSeverity.critical,
          status: IncidentStatus.resolved,
          title: 'Pet Attempted to Escape',
          description: 'Buddy managed to open his cage door and was found in the hallway.',
          reportedDate: now.subtract(const Duration(hours: 12)),
          reportedBy: 'Security Staff',
          occurredDate: now.subtract(const Duration(hours: 12)),
          resolvedDate: now.subtract(const Duration(hours: 11)),
          location: 'Buddy\'s Room, Hallway',
          witnesses: 'Security Staff, Night Staff',
          actionsTaken: 'Immediate capture, enhanced security measures, cage lock upgrade',
          followUpRequired: 'Daily security checks, customer notification of incident',
          notes: 'No injuries to pet or staff. Security measures upgraded immediately.',
          requiresVeterinarian: false,
          requiresCustomerNotification: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now.subtract(const Duration(hours: 11)),
        ),
      ]);
    }
  }

  Future<List<Incident>> getAll() async {
    _initialize();
    return List.unmodifiable(_incidents);
  }

  Future<Incident?> getById(String id) async {
    _initialize();
    try {
      return _incidents.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Incident>> getByCustomerId(String customerId) async {
    _initialize();
    return _incidents.where((i) => i.customerId == customerId).toList();
  }

  Future<List<Incident>> getByPetId(String petId) async {
    _initialize();
    return _incidents.where((i) => i.petId == petId).toList();
  }

  Future<List<Incident>> getByType(IncidentType type) async {
    _initialize();
    return _incidents.where((i) => i.type == type).toList();
  }

  Future<List<Incident>> getBySeverity(IncidentSeverity severity) async {
    _initialize();
    return _incidents.where((i) => i.severity == severity).toList();
  }

  Future<List<Incident>> getByStatus(IncidentStatus status) async {
    _initialize();
    return _incidents.where((i) => i.status == status).toList();
  }

  Future<List<Incident>> getOpenIncidents() async {
    _initialize();
    return _incidents.where((i) => i.isOpen).toList();
  }

  Future<List<Incident>> getCriticalIncidents() async {
    _initialize();
    return _incidents.where((i) => i.isCritical).toList();
  }

  Future<List<Incident>> getRecentIncidents(int days) async {
    _initialize();
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: days));
    
    return _incidents.where((i) => i.reportedDate.isAfter(threshold)).toList();
  }

  Future<List<Incident>> getBlockingCheckIn() async {
    _initialize();
    return _incidents.where((i) => i.blocksCheckIn == true).toList();
  }

  Future<Incident> create(Incident incident) async {
    _initialize();
    final newIncident = incident.copyWith(
      id: 'i${_incidents.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _incidents.add(newIncident);
    return newIncident;
  }

  Future<Incident> update(Incident incident) async {
    _initialize();
    final index = _incidents.indexWhere((i) => i.id == incident.id);
    if (index != -1) {
      final updatedIncident = incident.copyWith(
        updatedAt: DateTime.now(),
      );
      _incidents[index] = updatedIncident;
      return updatedIncident;
    }
    throw Exception('Incident not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _incidents.removeAt(index);
      return true;
    }
    return false;
  }

  Future<Incident> updateStatus(String id, IncidentStatus status, {String? notes}) async {
    _initialize();
    final incident = await getById(id);
    if (incident == null) {
      throw Exception('Incident not found');
    }
    
    final updatedIncident = incident.copyWith(
      status: status,
      notes: notes ?? incident.notes,
      updatedAt: DateTime.now(),
    );
    
    Incident finalIncident = updatedIncident;
    if (status == IncidentStatus.resolved) {
      finalIncident = updatedIncident.copyWith(
        resolvedDate: DateTime.now(),
      );
    }
    
    return await update(finalIncident);
  }

  Future<List<Incident>> search(String query) async {
    _initialize();
    final lowercaseQuery = query.toLowerCase();
    return _incidents.where((i) =>
      i.customerName.toLowerCase().contains(lowercaseQuery) ||
      i.petName.toLowerCase().contains(lowercaseQuery) ||
      i.title.toLowerCase().contains(lowercaseQuery) ||
      i.description.toLowerCase().contains(lowercaseQuery) ||
      i.location?.toLowerCase().contains(lowercaseQuery) == true ||
      i.reportedBy.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<Map<String, int>> getStatusCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final incident in _incidents) {
      final status = incident.status.name;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, int>> getSeverityCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final incident in _incidents) {
      final severity = incident.severity.name;
      counts[severity] = (counts[severity] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, int>> getTypeCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final incident in _incidents) {
      final type = incident.type.name;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }
}
