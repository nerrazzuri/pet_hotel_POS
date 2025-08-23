import 'dart:math';
import '../../features/loyalty/domain/entities/loyalty_program.dart';
import '../../features/loyalty/domain/entities/loyalty_transaction.dart';

class LoyaltyDao {
  static final LoyaltyDao _instance = LoyaltyDao._internal();
  factory LoyaltyDao() => _instance;
  LoyaltyDao._internal();

  final List<LoyaltyProgram> _loyaltyPrograms = [];
  final List<LoyaltyTransaction> _loyaltyTransactions = [];

  Future<void> init() async {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample loyalty tiers
    final bronzeTier = LoyaltyTier(
      id: 'tier_bronze',
      name: 'Bronze',
      description: 'Basic loyalty member',
      minPoints: 0,
      discountPercentage: 5.0,
      benefits: ['5% discount on services', 'Priority booking'],
      color: '#CD7F32',
      icon: '🥉',
    );

    final silverTier = LoyaltyTier(
      id: 'tier_silver',
      name: 'Silver',
      description: 'Silver loyalty member',
      minPoints: 1000,
      discountPercentage: 10.0,
      benefits: [
        '10% discount on services',
        'Priority booking',
        'Free nail trimming',
        'Birthday treats'
      ],
      color: '#C0C0C0',
      icon: '🥈',
    );

    final goldTier = LoyaltyTier(
      id: 'tier_gold',
      name: 'Gold',
      description: 'Gold loyalty member',
      minPoints: 5000,
      discountPercentage: 15.0,
      benefits: [
        '15% discount on services',
        'Priority booking',
        'Free nail trimming',
        'Birthday treats',
        'Free grooming session',
        'VIP customer service'
      ],
      color: '#FFD700',
      icon: '🥇',
    );

    final platinumTier = LoyaltyTier(
      id: 'tier_platinum',
      name: 'Platinum',
      description: 'Platinum loyalty member',
      minPoints: 10000,
      discountPercentage: 20.0,
      benefits: [
        '20% discount on services',
        'Priority booking',
        'Free nail trimming',
        'Birthday treats',
        'Free grooming session',
        'VIP customer service',
        'Free pet taxi service',
        'Exclusive events access'
      ],
      color: '#E5E4E2',
      icon: '💎',
    );

    // Sample loyalty rules
    final loyaltyRules = LoyaltyRules(
      pointsPerRinggit: 1.0,
      pointsPerNight: 50.0,
      pointsPerService: 25.0,
      pointsExpiryMonths: 12,
      minimumRedemptionAmount: 10.0,
      excludedServices: ['Vaccination', 'Medical treatment'],
      excludedProducts: ['Prescription food', 'Medication'],
    );

    // Sample loyalty program
    final loyaltyProgram = LoyaltyProgram(
      id: 'program_main',
      name: 'Cat Hotel Loyalty Program',
      description: 'Earn points for every stay and service',
      tiers: [bronzeTier, silverTier, goldTier, platinumTier],
      rules: loyaltyRules,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    _loyaltyPrograms.add(loyaltyProgram);

    // Sample loyalty transactions
    _loyaltyTransactions.addAll([
      LoyaltyTransaction(
        id: 'tx_001',
        customerId: 'customer_001',
        type: LoyaltyTransactionType.earned,
        status: LoyaltyTransactionStatus.completed,
        points: 150,
        description: 'Points earned from boarding stay',
        referenceId: 'booking_001',
        referenceType: 'boarding',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        processedAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 360)),
        notes: 'Points earned from boarding stay',
      ),
      LoyaltyTransaction(
        id: 'tx_002',
        customerId: 'customer_002',
        type: LoyaltyTransactionType.earned,
        status: LoyaltyTransactionStatus.completed,
        points: 75,
        description: 'Points earned from grooming service',
        referenceId: 'service_001',
        referenceType: 'grooming',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        processedAt: DateTime.now().subtract(const Duration(days: 3)),
        expiresAt: DateTime.now().add(const Duration(days: 362)),
        notes: 'Points earned from grooming service',
      ),
      LoyaltyTransaction(
        id: 'tx_003',
        customerId: 'customer_001',
        type: LoyaltyTransactionType.redeemed,
        status: LoyaltyTransactionStatus.completed,
        points: -50,
        description: 'Points redeemed for discount',
        referenceId: 'booking_002',
        referenceType: 'boarding',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: null,
        notes: 'Points redeemed for discount',
      ),
    ]);
  }

  // Loyalty Program methods
  Future<List<LoyaltyProgram>> getAllLoyaltyPrograms() async {
    return List.unmodifiable(_loyaltyPrograms);
  }

  Future<LoyaltyProgram?> getLoyaltyProgramById(String id) async {
    try {
      return _loyaltyPrograms.firstWhere((program) => program.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<LoyaltyProgram?> getActiveLoyaltyProgram() async {
    try {
      return _loyaltyPrograms.firstWhere((program) => program.isActive);
    } catch (e) {
      return null;
    }
  }

  Future<LoyaltyProgram> createLoyaltyProgram(LoyaltyProgram program) async {
    final newProgram = program.copyWith(
      id: 'program_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _loyaltyPrograms.add(newProgram);
    return newProgram;
  }

  Future<LoyaltyProgram> updateLoyaltyProgram(LoyaltyProgram program) async {
    final index = _loyaltyPrograms.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      final updatedProgram = program.copyWith(updatedAt: DateTime.now());
      _loyaltyPrograms[index] = updatedProgram;
      return updatedProgram;
    }
    throw Exception('Loyalty program not found');
  }

  Future<void> deleteLoyaltyProgram(String id) async {
    _loyaltyPrograms.removeWhere((program) => program.id == id);
  }

  // Loyalty Transaction methods
  Future<List<LoyaltyTransaction>> getAllLoyaltyTransactions() async {
    return List.unmodifiable(_loyaltyTransactions);
  }

  Future<LoyaltyTransaction?> getLoyaltyTransactionById(String id) async {
    try {
      return _loyaltyTransactions.firstWhere((tx) => tx.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<LoyaltyTransaction>> getLoyaltyTransactionsByCustomerId(String customerId) async {
    return _loyaltyTransactions
        .where((tx) => tx.customerId == customerId)
        .toList();
  }

  Future<List<LoyaltyTransaction>> getLoyaltyTransactionsByType(LoyaltyTransactionType type) async {
    return _loyaltyTransactions
        .where((tx) => tx.type == type)
        .toList();
  }

  Future<List<LoyaltyTransaction>> getLoyaltyTransactionsByStatus(LoyaltyTransactionStatus status) async {
    return _loyaltyTransactions
        .where((tx) => tx.status == status)
        .toList();
  }

  Future<LoyaltyTransaction> createLoyaltyTransaction(LoyaltyTransaction transaction) async {
    final newTransaction = transaction.copyWith(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _loyaltyTransactions.add(newTransaction);
    return newTransaction;
  }

  Future<LoyaltyTransaction> updateLoyaltyTransaction(LoyaltyTransaction transaction) async {
    final index = _loyaltyTransactions.indexWhere((tx) => tx.id == transaction.id);
    if (index != -1) {
      final updatedTransaction = transaction.copyWith(
        processedAt: DateTime.now(),
      );
      _loyaltyTransactions[index] = updatedTransaction;
      return updatedTransaction;
    }
    throw Exception('Loyalty transaction not found');
  }

  Future<void> deleteLoyaltyTransaction(String id) async {
    _loyaltyTransactions.removeWhere((tx) => tx.id == id);
  }

  // Helper methods
  Future<int> getCustomerTotalPoints(String customerId) async {
    final transactions = await getLoyaltyTransactionsByCustomerId(customerId);
    return transactions.fold<int>(0, (sum, tx) => sum + tx.points);
  }

  Future<LoyaltyTier?> getCustomerTier(String customerId) async {
    final totalPoints = await getCustomerTotalPoints(customerId);
    final program = await getActiveLoyaltyProgram();
    if (program == null) return null;

    // Sort tiers by minPoints in descending order to find the highest applicable tier
    final sortedTiers = List<LoyaltyTier>.from(program.tiers)
      ..sort((a, b) => b.minPoints.compareTo(a.minPoints));

    for (final tier in sortedTiers) {
      if (totalPoints >= tier.minPoints) {
        return tier;
      }
    }
    return null;
  }

  Future<List<LoyaltyTransaction>> getExpiringTransactions(int daysThreshold) async {
    final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));
    return _loyaltyTransactions
        .where((tx) => 
            tx.expiresAt != null && 
            tx.expiresAt!.isBefore(thresholdDate) &&
            tx.status == LoyaltyTransactionStatus.completed)
        .toList();
  }
}
