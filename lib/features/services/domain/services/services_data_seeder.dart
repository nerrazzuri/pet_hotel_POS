import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/core/services/service_package_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/product_bundle_dao.dart';

class ServicesDataSeeder {
  static final ServiceDao _serviceDao = ServiceDao();
  static final ServicePackageDao _packageDao = ServicePackageDao();
  static final ProductDao _productDao = ProductDao();
  static final ProductBundleDao _bundleDao = ProductBundleDao();

  static Future<void> seedAllData() async {
    await _seedServices();
    await _seedServicePackages();
    await _seedProducts();
    await _seedProductBundles();
  }

  static Future<void> _seedServices() async {
    // Boarding Services
    await _serviceDao.create(Service(
      id: 'boarding_001',
      serviceCode: 'BOARD-001',
      name: 'Standard Boarding',
      category: ServiceCategory.boarding,
      price: 35.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Standard boarding with basic care and feeding',
      duration: 1440, // 24 hours
      tags: ['boarding', 'standard', 'overnight'],
      specifications: {
        'includesFeeding': true,
        'includesCleaning': true,
        'includesPlaytime': true,
        'maxPetsPerRoom': 1,
      },
      requirements: ['Vaccination records', 'Health check'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '48 hours notice required',
      depositRequired: 50.00,
    ));

    await _serviceDao.create(Service(
      id: 'boarding_002',
      serviceCode: 'BOARD-002',
      name: 'Premium Boarding',
      category: ServiceCategory.boarding,
      price: 55.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Premium boarding with luxury amenities and extra care',
      duration: 1440, // 24 hours
      tags: ['boarding', 'premium', 'luxury'],
      specifications: {
        'includesFeeding': true,
        'includesCleaning': true,
        'includesPlaytime': true,
        'includesWebcam': true,
        'includesGrooming': true,
        'maxPetsPerRoom': 1,
      },
      requirements: ['Vaccination records', 'Health check'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '48 hours notice required',
      depositRequired: 100.00,
    ));

    // Daycare Services
    await _serviceDao.create(Service(
      id: 'daycare_001',
      serviceCode: 'DAY-001',
      name: 'Half-Day Daycare',
      category: ServiceCategory.daycare,
      price: 25.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Half-day daycare with supervised play and activities',
      duration: 240, // 4 hours
      tags: ['daycare', 'half-day', 'play'],
      specifications: {
        'includesPlaytime': true,
        'includesFeeding': true,
        'includesActivities': true,
        'maxPetsPerSession': 10,
      },
      requirements: ['Vaccination records', 'Health check'],
      requiresAppointment: false,
      maxPetsPerSession: 10,
      cancellationPolicy: '24 hours notice required',
    ));

    await _serviceDao.create(Service(
      id: 'daycare_002',
      serviceCode: 'DAY-002',
      name: 'Full-Day Daycare',
      category: ServiceCategory.daycare,
      price: 45.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Full-day daycare with extended activities and care',
      duration: 480, // 8 hours
      tags: ['daycare', 'full-day', 'extended'],
      specifications: {
        'includesPlaytime': true,
        'includesFeeding': true,
        'includesActivities': true,
        'includesRestPeriods': true,
        'maxPetsPerSession': 15,
      },
      requirements: ['Vaccination records', 'Health check'],
      requiresAppointment: false,
      maxPetsPerSession: 15,
      cancellationPolicy: '24 hours notice required',
    ));

    // Grooming Services
    await _serviceDao.create(Service(
      id: 'grooming_001',
      serviceCode: 'GROOM-001',
      name: 'Basic Grooming',
      category: ServiceCategory.grooming,
      price: 45.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic grooming including bath, brush, and nail trim',
      duration: 60,
      tags: ['grooming', 'basic', 'bath'],
      specifications: {
        'includesBath': true,
        'includesBrush': true,
        'includesNailTrim': true,
        'includesEarCleaning': false,
      },
      requirements: ['Pet must be healthy', 'No aggressive behavior'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
      depositRequired: 25.00,
    ));

    await _serviceDao.create(Service(
      id: 'grooming_002',
      serviceCode: 'GROOM-002',
      name: 'Premium Grooming',
      category: ServiceCategory.grooming,
      price: 75.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Premium grooming with full styling and spa treatment',
      duration: 90,
      tags: ['grooming', 'premium', 'styling'],
      specifications: {
        'includesBath': true,
        'includesBrush': true,
        'includesNailTrim': true,
        'includesEarCleaning': true,
        'includesHaircut': true,
        'includesSpaTreatment': true,
      },
      requirements: ['Pet must be healthy', 'No aggressive behavior'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
      depositRequired: 50.00,
    ));

    // Add-on Services
    await _serviceDao.create(Service(
      id: 'addon_001',
      serviceCode: 'ADD-001',
      name: 'Extra Playtime',
      category: ServiceCategory.addOns,
      price: 15.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Additional 30 minutes of supervised playtime',
      duration: 30,
      tags: ['addon', 'playtime', 'extra'],
      specifications: {
        'playType': 'supervised',
        'maxPetsPerSession': 3,
      },
      requirements: ['Must be enrolled in boarding or daycare'],
      requiresAppointment: false,
      maxPetsPerSession: 3,
    ));

    await _serviceDao.create(Service(
      id: 'addon_002',
      serviceCode: 'ADD-002',
      name: 'Medication Administration',
      category: ServiceCategory.addOns,
      price: 10.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Administer medication during stay',
      duration: 15,
      tags: ['addon', 'medication', 'health'],
      specifications: {
        'medicationType': 'oral',
        'frequency': 'as prescribed',
      },
      requirements: ['Prescription required', 'Owner instructions'],
      requiresAppointment: false,
      maxPetsPerSession: 1,
    ));

    // Training Services
    await _serviceDao.create(Service(
      id: 'training_001',
      serviceCode: 'TRAIN-001',
      name: 'Basic Obedience',
      category: ServiceCategory.training,
      price: 60.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic obedience training for cats',
      duration: 45,
      tags: ['training', 'obedience', 'basic'],
      specifications: {
        'sessionType': 'individual',
        'includesMaterials': true,
        'followUpSupport': true,
      },
      requirements: ['Pet must be healthy', 'Owner participation required'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '48 hours notice required',
    ));

    // Wellness Services
    await _serviceDao.create(Service(
      id: 'wellness_001',
      serviceCode: 'WELL-001',
      name: 'Health Check-up',
      category: ServiceCategory.wellness,
      price: 35.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic health check-up and consultation',
      duration: 30,
      tags: ['wellness', 'health', 'checkup'],
      specifications: {
        'includesExam': true,
        'includesConsultation': true,
        'includesRecommendations': true,
      },
      requirements: ['Pet must be calm'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
    ));
  }

  static Future<void> _seedServicePackages() async {
    // Daycare Package
    await _packageDao.create(ServicePackage(
      id: 'package_001',
      name: '10-Day Daycare Pass',
      description: 'Save money with a 10-day daycare package',
      price: 400.00,
      validityDays: 90,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['daycare_002'],
      discountPercentage: 11.1, // Save $50 on $450
      discountReason: 'Bulk purchase discount',
      maxUses: 10,
      termsAndConditions: 'Valid for 90 days, non-refundable, non-transferable',
      restrictions: ['Cannot be used for boarding', 'Subject to availability'],
    ));

    // Grooming Package
    await _packageDao.create(ServicePackage(
      id: 'package_002',
      name: 'Grooming & Wellness Combo',
      description: 'Combine grooming with wellness check for savings',
      price: 100.00,
      validityDays: 30,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['grooming_001', 'wellness_001'],
      discountPercentage: 20.0, // Save $20 on $120
      discountReason: 'Service combination discount',
      maxUses: 1,
      termsAndConditions: 'Valid for 30 days, must be used together',
      restrictions: ['Services must be booked together'],
    ));

    // Premium Package
    await _packageDao.create(ServicePackage(
      id: 'package_003',
      name: 'Luxury Stay Package',
      description: 'Premium boarding with grooming and wellness',
      price: 150.00,
      validityDays: 7,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['boarding_002', 'grooming_002', 'wellness_001'],
      discountPercentage: 25.0, // Save $50 on $200
      discountReason: 'Premium package discount',
      maxUses: 1,
      termsAndConditions: 'Valid for 7 days, premium services included',
      restrictions: ['Must be booked as a package'],
    ));
  }

  static Future<void> _seedProducts() async {
    // Pet Food
    await _productDao.create(Product(
      id: 'product_001',
      productCode: 'FOOD-001',
      name: 'Premium Cat Food',
      category: ProductCategory.petFood,
      isActive: true,
      price: 25.99,
      cost: 15.00,
      stockQuantity: 100,
      reorderPoint: 20,
      status: ProductStatus.inStock,
      description: 'High-quality premium cat food with balanced nutrition',
      barcode: '1234567890123',
      supplier: 'Premium Pet Foods Inc.',
      brand: 'CatCare Premium',
      size: '5kg',
      weight: '5kg',
      unit: 'bag',
      imageUrl: 'assets/images/products/cat_food.jpg',
      tags: ['food', 'premium', 'balanced'],
      specifications: {
        'protein': '32%',
        'fat': '18%',
        'fiber': '3%',
        'lifeStage': 'adult',
      },
      notes: 'Best seller, high protein content',
      location: 'Warehouse A, Shelf 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await _productDao.create(Product(
      id: 'product_002',
      productCode: 'FOOD-002',
      name: 'Kitten Formula',
      category: ProductCategory.petFood,
      isActive: true,
      price: 18.99,
      cost: 12.00,
      stockQuantity: 50,
      reorderPoint: 15,
      status: ProductStatus.inStock,
      description: 'Specialized formula for kittens under 1 year',
      barcode: '1234567890124',
      supplier: 'Premium Pet Foods Inc.',
      brand: 'CatCare Kitten',
      size: '2kg',
      weight: '2kg',
      unit: 'bag',
      imageUrl: 'assets/images/products/kitten_food.jpg',
      tags: ['food', 'kitten', 'formula'],
      specifications: {
        'protein': '35%',
        'fat': '20%',
        'fiber': '2%',
        'lifeStage': 'kitten',
      },
      notes: 'High calorie for growing kittens',
      location: 'Warehouse A, Shelf 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Treats
    await _productDao.create(Product(
      id: 'product_003',
      productCode: 'TREAT-001',
      name: 'Cat Treats',
      category: ProductCategory.treats,
      isActive: true,
      price: 8.99,
      cost: 4.50,
      stockQuantity: 200,
      reorderPoint: 30,
      status: ProductStatus.inStock,
      description: 'Delicious cat treats for training and rewards',
      barcode: '1234567890125',
      supplier: 'Treats Co.',
      brand: 'CatRewards',
      size: '100g',
      weight: '100g',
      unit: 'pack',
      imageUrl: 'assets/images/products/cat_treats.jpg',
      tags: ['treats', 'training', 'rewards'],
      specifications: {
        'protein': '28%',
        'fat': '12%',
        'calories': '3 per treat',
      },
      notes: 'Popular training treat',
      location: 'Warehouse A, Shelf 2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Toys
    await _productDao.create(Product(
      id: 'product_004',
      productCode: 'TOY-001',
      name: 'Interactive Cat Toy',
      category: ProductCategory.toys,
      isActive: true,
      price: 15.99,
      cost: 8.00,
      stockQuantity: 75,
      reorderPoint: 20,
      status: ProductStatus.inStock,
      description: 'Interactive toy that stimulates natural hunting instincts',
      barcode: '1234567890126',
      supplier: 'Toy World',
      brand: 'PlaySmart',
      size: 'Medium',
      color: 'Multi-color',
      imageUrl: 'assets/images/products/cat_toy.jpg',
      tags: ['toys', 'interactive', 'hunting'],
      specifications: {
        'material': 'Plastic and fabric',
        'batteryRequired': false,
        'ageRange': 'All ages',
      },
      notes: 'Great for indoor cats',
      location: 'Warehouse A, Shelf 3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Grooming Supplies
    await _productDao.create(Product(
      id: 'product_005',
      productCode: 'GROOM-001',
      name: 'Cat Brush',
      category: ProductCategory.grooming,
      isActive: true,
      price: 12.99,
      cost: 6.50,
      stockQuantity: 60,
      reorderPoint: 15,
      status: ProductStatus.inStock,
      description: 'Professional cat brush for daily grooming',
      barcode: '1234567890127',
      supplier: 'Grooming Supplies Ltd.',
      brand: 'ProGroom',
      size: 'Standard',
      color: 'Black',
      imageUrl: 'assets/images/products/cat_brush.jpg',
      tags: ['grooming', 'brush', 'daily'],
      specifications: {
        'bristleType': 'Soft',
        'handleMaterial': 'Wood',
        'suitableFor': 'All coat types',
      },
      notes: 'Essential grooming tool',
      location: 'Warehouse A, Shelf 4',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Health & Wellness
    await _productDao.create(Product(
      id: 'product_006',
      productCode: 'HEALTH-001',
      name: 'Cat Vitamins',
      category: ProductCategory.health,
      isActive: true,
      price: 22.99,
      cost: 14.00,
      stockQuantity: 40,
      reorderPoint: 10,
      status: ProductStatus.inStock,
      description: 'Complete vitamin supplement for cats',
      barcode: '1234567890128',
      supplier: 'Health Plus',
      brand: 'VitaCat',
      size: '60 tablets',
      weight: '60g',
      unit: 'bottle',
      imageUrl: 'assets/images/products/cat_vitamins.jpg',
      tags: ['health', 'vitamins', 'supplement'],
      specifications: {
        'vitaminA': '5000 IU',
        'vitaminD': '400 IU',
        'vitaminE': '30 IU',
        'dosage': '1 tablet daily',
      },
      notes: 'Supports overall health',
      location: 'Warehouse A, Shelf 5',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Low stock product for testing
    await _productDao.create(Product(
      id: 'product_007',
      productCode: 'LOW-001',
      name: 'Limited Stock Item',
      category: ProductCategory.accessories,
      isActive: true,
      price: 9.99,
      cost: 5.00,
      stockQuantity: 5,
      reorderPoint: 10,
      status: ProductStatus.lowStock,
      description: 'Test product for low stock alerts',
      barcode: '1234567890129',
      supplier: 'Test Supplier',
      brand: 'Test Brand',
      size: 'Small',
      color: 'Red',
      imageUrl: 'assets/images/products/test_item.jpg',
      tags: ['test', 'low-stock'],
      notes: 'Testing low stock functionality',
      location: 'Warehouse A, Shelf 6',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  static Future<void> _seedProductBundles() async {
    // Starter Kit Bundle
    await _bundleDao.create(ProductBundle(
      id: 'bundle_001',
      name: 'New Cat Starter Kit',
      description: 'Everything a new cat owner needs to get started',
      price: 65.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_001', 'product_003', 'product_004', 'product_005'],
      productQuantities: {
        'product_001': 1,
        'product_003': 2,
        'product_004': 1,
        'product_005': 1,
      },
      discountPercentage: 15.0, // Save $15 on $80
      discountReason: 'Starter kit bundle discount',
      termsAndConditions: 'Bundle items cannot be exchanged individually',
      restrictions: ['Non-refundable', 'Cannot be split'],
    ));

    // Health & Wellness Bundle
    await _bundleDao.create(ProductBundle(
      id: 'bundle_002',
      name: 'Health & Wellness Bundle',
      description: 'Complete health support for your cat',
      price: 40.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_006', 'product_003'],
      productQuantities: {
        'product_006': 1,
        'product_003': 3,
      },
      discountPercentage: 20.0, // Save $10 on $50
      discountReason: 'Health bundle discount',
      termsAndConditions: 'Health products have expiration dates',
      restrictions: ['Check expiration dates', 'Non-refundable'],
    ));

    // Premium Care Bundle
    await _bundleDao.create(ProductBundle(
      id: 'bundle_003',
      name: 'Premium Care Bundle',
      description: 'Premium products for discerning cat owners',
      price: 120.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_001', 'product_004', 'product_006'],
      productQuantities: {
        'product_001': 2,
        'product_004': 2,
        'product_006': 1,
      },
      discountPercentage: 25.0, // Save $40 on $160
      discountReason: 'Premium bundle discount',
      termsAndConditions: 'Premium products with extended warranty',
      restrictions: ['Premium pricing', 'Extended warranty applies'],
    ));
  }

  // Utility method to clear all data (for testing)
  static Future<void> clearAllData() async {
    // Note: This would need to be implemented in the DAOs
    // For now, we'll just log that this was called
    print('ServicesDataSeeder: clearAllData() called');
  }

  // Utility method to check if data exists
  static Future<bool> hasData() async {
    try {
      final services = await _serviceDao.getAll();
      final products = await _productDao.getAll();
      return services.isNotEmpty || products.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
