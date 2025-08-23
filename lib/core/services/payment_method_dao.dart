import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';

class PaymentMethodDao {
  static final Map<String, PaymentMethod> _paymentMethods = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;

    // Create sample payment methods
    _paymentMethods['pm_001'] = PaymentMethod(
      id: 'pm_001',
      name: 'Cash',
      type: PaymentType.cash,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Cash payments',
      iconPath: 'assets/icons/cash.png',
      configuration: {'requiresChange': true},
      processingFee: 0.0,
      minimumAmount: 0.01,
      maximumAmount: 10000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Standard cash payment method',
    );

    _paymentMethods['pm_002'] = PaymentMethod(
      id: 'pm_002',
      name: 'Credit Card',
      type: PaymentType.creditCard,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Credit card payments',
      iconPath: 'assets/icons/credit_card.png',
      configuration: {'requiresSignature': true, 'chipEnabled': true},
      processingFee: 2.5,
      minimumAmount: 1.0,
      maximumAmount: 50000.0,
      supportedCurrencies: ['MYR', 'USD'],
      requiresSignature: true,
      requiresReceipt: true,
      notes: 'Visa, MasterCard, American Express',
    );

    _paymentMethods['pm_003'] = PaymentMethod(
      id: 'pm_003',
      name: 'Debit Card',
      type: PaymentType.debitCard,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Debit card payments',
      iconPath: 'assets/icons/debit_card.png',
      configuration: {'requiresPin': true, 'chipEnabled': true},
      processingFee: 1.5,
      minimumAmount: 1.0,
      maximumAmount: 25000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Local bank debit cards',
    );

    _paymentMethods['pm_004'] = PaymentMethod(
      id: 'pm_004',
      name: 'Digital Wallet',
      type: PaymentType.digitalWallet,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'E-wallet payments',
      iconPath: 'assets/icons/digital_wallet.png',
      configuration: {'qrEnabled': true, 'nfcEnabled': true},
      processingFee: 1.0,
      minimumAmount: 0.01,
      maximumAmount: 10000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Touch n Go, GrabPay, Boost',
    );

    _paymentMethods['pm_005'] = PaymentMethod(
      id: 'pm_005',
      name: 'Bank Transfer',
      type: PaymentType.bankTransfer,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Direct bank transfers',
      iconPath: 'assets/icons/bank_transfer.png',
      configuration: {'requiresConfirmation': true},
      processingFee: 0.0,
      minimumAmount: 10.0,
      maximumAmount: 100000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'FPX, DuitNow, bank transfers',
    );

    _paymentMethods['pm_006'] = PaymentMethod(
      id: 'pm_006',
      name: 'Voucher',
      type: PaymentType.voucher,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Gift vouchers and coupons',
      iconPath: 'assets/icons/voucher.png',
      configuration: {'requiresValidation': true},
      processingFee: 0.0,
      minimumAmount: 0.01,
      maximumAmount: 10000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Gift vouchers, loyalty points, coupons',
    );

    _paymentMethods['pm_007'] = PaymentMethod(
      id: 'pm_007',
      name: 'Deposit',
      type: PaymentType.deposit,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Customer deposits',
      iconPath: 'assets/icons/deposit.png',
      configuration: {'requiresReceipt': true},
      processingFee: 0.0,
      minimumAmount: 10.0,
      maximumAmount: 50000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Customer deposits for future services',
    );

    _paymentMethods['pm_008'] = PaymentMethod(
      id: 'pm_008',
      name: 'Partial Payment',
      type: PaymentType.partialPayment,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Partial payment processing',
      iconPath: 'assets/icons/partial_payment.png',
      configuration: {'allowsMultiplePayments': true},
      processingFee: 0.0,
      minimumAmount: 0.01,
      maximumAmount: 100000.0,
      supportedCurrencies: ['MYR'],
      requiresSignature: false,
      requiresReceipt: true,
      notes: 'Split payments and partial settlements',
    );

    _initialized = true;
  }

  Future<List<PaymentMethod>> getAll() async {
    _initialize();
    return _paymentMethods.values.toList();
  }

  Future<PaymentMethod?> getById(String id) async {
    _initialize();
    return _paymentMethods[id];
  }

  Future<List<PaymentMethod>> getActiveMethods() async {
    _initialize();
    return _paymentMethods.values
        .where((method) => method.isActive)
        .toList();
  }

  Future<List<PaymentMethod>> getByType(PaymentType type) async {
    _initialize();
    return _paymentMethods.values
        .where((method) => method.type == type && method.isActive)
        .toList();
  }

  Future<PaymentMethod> create(PaymentMethod method) async {
    _initialize();
    _paymentMethods[method.id] = method;
    return method;
  }

  Future<PaymentMethod> update(PaymentMethod method) async {
    _initialize();
    _paymentMethods[method.id] = method;
    return method;
  }

  Future<void> delete(String id) async {
    _initialize();
    _paymentMethods.remove(id);
  }

  Future<void> deactivate(String id) async {
    _initialize();
    final method = _paymentMethods[id];
    if (method != null) {
      _paymentMethods[id] = method.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> activate(String id) async {
    _initialize();
    final method = _paymentMethods[id];
    if (method != null) {
      _paymentMethods[id] = method.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );
    }
  }
}
