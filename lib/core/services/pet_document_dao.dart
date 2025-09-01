import 'package:cat_hotel_pos/features/customers/domain/entities/pet_document.dart';

class PetDocumentDao {
  static final PetDocumentDao _instance = PetDocumentDao._internal();
  factory PetDocumentDao() => _instance;
  PetDocumentDao._internal();

  final List<PetDocument> _documents = [];

  void _initialize() {
    if (_documents.isEmpty) {
      final now = DateTime.now();
      
      _documents.addAll([
        PetDocument(
          id: 'doc1',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          type: DocumentType.vaccinationCertificate,
          fileName: 'whiskers_vaccination_2024.pdf',
          fileUrl: '/uploads/documents/whiskers_vaccination_2024.pdf',
          fileType: 'application/pdf',
          fileSize: 245760,
          status: DocumentStatus.approved,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 30)),
          title: 'Annual Vaccination Certificate',
          description: 'Rabies and FVRCP vaccination certificate for 2024',
          expiryDate: now.add(const Duration(days: 335)),
          uploadedBy: 'Dr. Sarah Chen',
          approvedBy: 'admin',
          approvedAt: now.subtract(const Duration(days: 29)),
          isRequired: true,
          isPublic: false,
          version: 1,
        ),
        PetDocument(
          id: 'doc2',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          type: DocumentType.photo,
          fileName: 'whiskers_photo_2024.jpg',
          fileUrl: '/uploads/photos/whiskers_photo_2024.jpg',
          fileType: 'image/jpeg',
          fileSize: 512000,
          status: DocumentStatus.approved,
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 15)),
          title: 'Whiskers Profile Photo',
          description: 'Recent photo of Whiskers for identification',
          uploadedBy: 'John Doe',
          approvedBy: 'admin',
          approvedAt: now.subtract(const Duration(days: 14)),
          isRequired: false,
          isPublic: true,
          thumbnailUrl: '/uploads/photos/thumbnails/whiskers_photo_2024.jpg',
          version: 1,
        ),
        PetDocument(
          id: 'doc3',
          petId: 'pet_002',
          petName: 'Buddy',
          customerId: 'cust_002',
          customerName: 'Jane Smith',
          type: DocumentType.medicalRecord,
          fileName: 'buddy_medical_record_2024.pdf',
          fileUrl: '/uploads/documents/buddy_medical_record_2024.pdf',
          fileType: 'application/pdf',
          fileSize: 1024000,
          status: DocumentStatus.pending,
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
          title: 'Medical History Record',
          description: 'Complete medical history and treatment records',
          uploadedBy: 'Dr. Michael Wong',
          isRequired: true,
          isPublic: false,
          version: 1,
        ),
        PetDocument(
          id: 'doc4',
          petId: 'pet_003',
          petName: 'Luna',
          customerId: 'cust_003',
          customerName: 'Mike Johnson',
          type: DocumentType.microchipCertificate,
          fileName: 'luna_microchip_cert.pdf',
          fileUrl: '/uploads/documents/luna_microchip_cert.pdf',
          fileType: 'application/pdf',
          fileSize: 153600,
          status: DocumentStatus.approved,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now.subtract(const Duration(days: 60)),
          title: 'Microchip Registration Certificate',
          description: 'Official microchip registration certificate',
          uploadedBy: 'Mike Johnson',
          approvedBy: 'admin',
          approvedAt: now.subtract(const Duration(days: 59)),
          isRequired: true,
          isPublic: false,
          version: 1,
        ),
        PetDocument(
          id: 'doc5',
          petId: 'pet_004',
          petName: 'Max',
          customerId: 'cust_004',
          customerName: 'Sarah Wilson',
          type: DocumentType.behaviorAssessment,
          fileName: 'max_behavior_assessment_2024.pdf',
          fileUrl: '/uploads/documents/max_behavior_assessment_2024.pdf',
          fileType: 'application/pdf',
          fileSize: 307200,
          status: DocumentStatus.approved,
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
          title: 'Behavior Assessment Report',
          description: 'Professional behavior assessment and recommendations',
          uploadedBy: 'Dr. Emily Brown',
          approvedBy: 'admin',
          approvedAt: now.subtract(const Duration(days: 9)),
          isRequired: false,
          isPublic: false,
          version: 1,
        ),
      ]);
    }
  }

  Future<List<PetDocument>> getAll() async {
    _initialize();
    return _documents;
  }

  Future<PetDocument?> getById(String id) async {
    _initialize();
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<PetDocument>> getByPetId(String petId) async {
    _initialize();
    return _documents.where((doc) => doc.petId == petId).toList();
  }

  Future<List<PetDocument>> getByCustomerId(String customerId) async {
    _initialize();
    return _documents.where((doc) => doc.customerId == customerId).toList();
  }

  Future<List<PetDocument>> getByType(DocumentType type) async {
    _initialize();
    return _documents.where((doc) => doc.type == type).toList();
  }

  Future<List<PetDocument>> getByStatus(DocumentStatus status) async {
    _initialize();
    return _documents.where((doc) => doc.status == status).toList();
  }

  Future<List<PetDocument>> getRequired() async {
    _initialize();
    return _documents.where((doc) => doc.isRequired == true).toList();
  }

  Future<List<PetDocument>> getExpired() async {
    _initialize();
    return _documents.where((doc) => doc.isExpired).toList();
  }

  Future<List<PetDocument>> getExpiringSoon() async {
    _initialize();
    return _documents.where((doc) => doc.isExpiringSoon).toList();
  }

  Future<List<PetDocument>> getPublic() async {
    _initialize();
    return _documents.where((doc) => doc.isPublic == true).toList();
  }

  Future<PetDocument> create(PetDocument document) async {
    _initialize();
    final newDocument = document.copyWith(
      id: 'doc${_documents.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _documents.add(newDocument);
    return newDocument;
  }

  Future<PetDocument> update(PetDocument document) async {
    _initialize();
    final index = _documents.indexWhere((doc) => doc.id == document.id);
    if (index != -1) {
      final updatedDocument = document.copyWith(
        updatedAt: DateTime.now(),
      );
      _documents[index] = updatedDocument;
      return updatedDocument;
    }
    throw Exception('Document not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      _documents.removeAt(index);
      return true;
    }
    return false;
  }

  Future<PetDocument> approveDocument(String id, String approvedBy) async {
    _initialize();
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      final document = _documents[index];
      final updatedDocument = document.copyWith(
        status: DocumentStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _documents[index] = updatedDocument;
      return updatedDocument;
    }
    throw Exception('Document not found');
  }

  Future<PetDocument> rejectDocument(String id, String rejectedBy, String reason) async {
    _initialize();
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      final document = _documents[index];
      final updatedDocument = document.copyWith(
        status: DocumentStatus.rejected,
        rejectionReason: reason,
        rejectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _documents[index] = updatedDocument;
      return updatedDocument;
    }
    throw Exception('Document not found');
  }

  Future<Map<String, dynamic>> getStatistics() async {
    _initialize();
    final total = _documents.length;
    final approved = _documents.where((doc) => doc.status == DocumentStatus.approved).length;
    final pending = _documents.where((doc) => doc.status == DocumentStatus.pending).length;
    final rejected = _documents.where((doc) => doc.status == DocumentStatus.rejected).length;
    final expired = _documents.where((doc) => doc.isExpired).length;
    final expiringSoon = _documents.where((doc) => doc.isExpiringSoon).length;

    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'expired': expired,
      'expiringSoon': expiringSoon,
      'approvalRate': total > 0 ? (approved / total * 100).toStringAsFixed(1) : '0.0',
    };
  }

  Future<List<PetDocument>> search(String query) async {
    _initialize();
    final lowercaseQuery = query.toLowerCase();
    return _documents.where((doc) =>
      doc.fileName.toLowerCase().contains(lowercaseQuery) ||
      doc.title?.toLowerCase().contains(lowercaseQuery) == true ||
      doc.description?.toLowerCase().contains(lowercaseQuery) == true ||
      doc.petName.toLowerCase().contains(lowercaseQuery) ||
      doc.customerName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
