import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';

class WaiverDao {
  static final WaiverDao _instance = WaiverDao._internal();
  factory WaiverDao() => _instance;
  WaiverDao._internal();

  final List<Waiver> _waivers = [];

  void _initialize() {
    if (_waivers.isEmpty) {
      final now = DateTime.now();
      
      _waivers.addAll([
        Waiver(
          id: 'w1',
          customerId: 'cust1',
          customerName: 'John Smith',
          petId: 'pet1',
          petName: 'Whiskers',
          type: WaiverType.boardingConsent,
          title: 'Boarding Consent Form',
          content: 'I hereby consent to boarding my pet at Cat Hotel. I understand the risks and agree to the terms.',
          status: WaiverStatus.signed,
          createdAt: now.subtract(const Duration(days: 30)),
          signedDate: now.subtract(const Duration(days: 30)),
          expiryDate: now.add(const Duration(days: 335)),
          signedBy: 'John Smith',
          signatureMethod: 'digital',
          witnessName: 'Staff Member',
          isRequired: true,
          blocksCheckIn: false,
          updatedAt: now.subtract(const Duration(days: 30)),
        ),
        Waiver(
          id: 'w2',
          customerId: 'cust1',
          customerName: 'John Smith',
          petId: 'pet1',
          petName: 'Whiskers',
          type: WaiverType.medicalTreatment,
          title: 'Medical Treatment Authorization',
          content: 'I authorize emergency medical treatment for my pet if necessary, up to \$500.',
          status: WaiverStatus.signed,
          createdAt: now.subtract(const Duration(days: 30)),
          signedDate: now.subtract(const Duration(days: 30)),
          expiryDate: now.add(const Duration(days: 335)),
          signedBy: 'John Smith',
          signatureMethod: 'digital',
          witnessName: 'Staff Member',
          isRequired: true,
          blocksCheckIn: false,
          updatedAt: now.subtract(const Duration(days: 30)),
        ),
        Waiver(
          id: 'w3',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          petId: 'pet2',
          petName: 'Buddy',
          type: WaiverType.boardingConsent,
          title: 'Boarding Consent Form',
          content: 'I hereby consent to boarding my pet at Cat Hotel. I understand the risks and agree to the terms.',
          status: WaiverStatus.pending,
          createdAt: now.subtract(const Duration(days: 15)),
          expiryDate: now.add(const Duration(days: 15)),
          isRequired: true,
          blocksCheckIn: true,
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
        Waiver(
          id: 'w4',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          petId: 'pet2',
          petName: 'Buddy',
          type: WaiverType.liabilityWaiver,
          title: 'Liability Waiver',
          content: 'I understand that Cat Hotel is not liable for any injuries or accidents that may occur during my pet\'s stay.',
          status: WaiverStatus.signed,
          createdAt: now.subtract(const Duration(days: 15)),
          signedDate: now.subtract(const Duration(days: 15)),
          expiryDate: now.add(const Duration(days: 350)),
          signedBy: 'Sarah Wilson',
          signatureMethod: 'digital',
          witnessName: 'Staff Member',
          isRequired: true,
          blocksCheckIn: false,
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
        Waiver(
          id: 'w5',
          customerId: 'cust3',
          customerName: 'Mike Davis',
          petId: 'pet3',
          petName: 'Luna',
          type: WaiverType.photoRelease,
          title: 'Photo Release Form',
          content: 'I consent to photos of my pet being used for marketing purposes.',
          status: WaiverStatus.signed,
          createdAt: now.subtract(const Duration(days: 7)),
          signedDate: now.subtract(const Duration(days: 7)),
          expiryDate: now.add(const Duration(days: 358)),
          signedBy: 'Mike Davis',
          signatureMethod: 'digital',
          witnessName: 'Staff Member',
          isRequired: false,
          blocksCheckIn: false,
          updatedAt: now.subtract(const Duration(days: 7)),
        ),
        Waiver(
          id: 'w6',
          customerId: 'cust3',
          customerName: 'Mike Davis',
          petId: 'pet3',
          petName: 'Luna',
          type: WaiverType.vaccinationWaiver,
          title: 'Vaccination Waiver',
          content: 'I understand the risks of not vaccinating my pet and accept responsibility.',
          status: WaiverStatus.signed,
          createdAt: now.subtract(const Duration(days: 7)),
          signedDate: now.subtract(const Duration(days: 7)),
          expiryDate: now.add(const Duration(days: 358)),
          signedBy: 'Mike Davis',
          signatureMethod: 'digital',
          witnessName: 'Staff Member',
          isRequired: false,
          blocksCheckIn: false,
          updatedAt: now.subtract(const Duration(days: 7)),
        ),
      ]);
    }
  }

  Future<List<Waiver>> getAll() async {
    _initialize();
    return List.unmodifiable(_waivers);
  }

  Future<Waiver?> getById(String id) async {
    _initialize();
    try {
      return _waivers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Waiver>> getByCustomerId(String customerId) async {
    _initialize();
    return _waivers.where((w) => w.customerId == customerId).toList();
  }

  Future<List<Waiver>> getByPetId(String petId) async {
    _initialize();
    return _waivers.where((w) => w.petId == petId).toList();
  }

  Future<List<Waiver>> getByType(WaiverType type) async {
    _initialize();
    return _waivers.where((w) => w.type == type).toList();
  }

  Future<List<Waiver>> getByStatus(WaiverStatus status) async {
    _initialize();
    return _waivers.where((w) => w.status == status).toList();
  }

  Future<List<Waiver>> getPendingSignatures() async {
    _initialize();
    return _waivers.where((w) => w.status == WaiverStatus.pending).toList();
  }

  Future<List<Waiver>> getExpiringSoon(int daysThreshold) async {
    _initialize();
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    
    return _waivers.where((w) => 
      w.expiryDate != null && 
      w.expiryDate!.isAfter(now) && 
      w.expiryDate!.isBefore(threshold)
    ).toList();
  }

  Future<List<Waiver>> getExpired() async {
    _initialize();
    final now = DateTime.now();
    return _waivers.where((w) => 
      w.expiryDate != null && w.expiryDate!.isBefore(now)
    ).toList();
  }

  Future<List<Waiver>> getBlockingCheckIn() async {
    _initialize();
    return _waivers.where((w) => w.blocksCheckIn == true).toList();
  }

  Future<Waiver> create(Waiver waiver) async {
    _initialize();
    final newWaiver = waiver.copyWith(
      id: 'w${_waivers.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _waivers.add(newWaiver);
    return newWaiver;
  }

  Future<Waiver> update(Waiver waiver) async {
    _initialize();
    final index = _waivers.indexWhere((w) => w.id == waiver.id);
    if (index != -1) {
      final updatedWaiver = waiver.copyWith(
        updatedAt: DateTime.now(),
      );
      _waivers[index] = updatedWaiver;
      return updatedWaiver;
    }
    throw Exception('Waiver not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _waivers.indexWhere((w) => w.id == id);
    if (index != -1) {
      _waivers.removeAt(index);
      return true;
    }
    return false;
  }

  Future<Waiver> signWaiver(String id, String signedBy, String signatureMethod, {String? witnessName}) async {
    _initialize();
    final waiver = await getById(id);
    if (waiver == null) {
      throw Exception('Waiver not found');
    }
    
    final signedWaiver = waiver.copyWith(
      status: WaiverStatus.signed,
      signedDate: DateTime.now(),
      signedBy: signedBy,
      signatureMethod: signatureMethod,
      witnessName: witnessName,
      updatedAt: DateTime.now(),
    );
    
    return await update(signedWaiver);
  }

  Future<List<Waiver>> search(String query) async {
    _initialize();
    final lowercaseQuery = query.toLowerCase();
    return _waivers.where((w) =>
      w.customerName.toLowerCase().contains(lowercaseQuery) ||
      (w.petName != null && w.petName!.toLowerCase().contains(lowercaseQuery)) ||
      w.title.toLowerCase().contains(lowercaseQuery) ||
      w.content.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<Map<String, int>> getStatusCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final waiver in _waivers) {
      final status = waiver.status.name;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, int>> getTypeCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final waiver in _waivers) {
      final type = waiver.type.name;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }
}
