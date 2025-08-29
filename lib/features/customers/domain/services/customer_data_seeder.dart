import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/core/services/vaccination_dao.dart';
import 'package:cat_hotel_pos/core/services/waiver_dao.dart';
import 'package:cat_hotel_pos/core/services/incident_dao.dart';

class CustomerDataSeeder {
  static final CustomerDao _customerDao = CustomerDao();
  static final PetDao _petDao = PetDao();
  static final VaccinationDao _vaccinationDao = VaccinationDao();
  static final WaiverDao _waiverDao = WaiverDao();
  static final IncidentDao _incidentDao = IncidentDao();

  static Future<void> seedAllData() async {
    try {
      print('CustomerDataSeeder: Starting to seed all data...');
      await _seedCustomers();
      await _seedPets();
      await _seedVaccinations();
      await _seedWaivers();
      await _seedIncidents();
      print('CustomerDataSeeder: All data seeded successfully!');
    } catch (e) {
      print('CustomerDataSeeder: Error seeding data: $e');
      rethrow;
    }
  }

  static Future<void> _seedCustomers() async {
    try {
      print('CustomerDataSeeder: Seeding customers...');
      
      // Sample customers with more diverse names for testing fuzzy search
      final customers = [
        Customer(
          id: 'cust_001',
          customerCode: 'CUST001',
          firstName: 'John',
          lastName: 'Smith',
          email: 'john.smith@email.com',
          phoneNumber: '+1-555-0101',
          status: CustomerStatus.active,
          source: CustomerSource.onlineBooking,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
          address: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          zipCode: '12345',
          country: 'USA',
          dateOfBirth: DateTime(1985, 3, 15),
          loyaltyTier: LoyaltyTier.gold,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 7)),
          totalSpent: 1250.00,
          notes: 'Prefers morning appointments',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_001',
              name: 'Jane Smith',
              relationship: 'Spouse',
              phoneNumber: '+1-555-0102',
              customerId: 'cust_001',
              email: 'jane.smith@email.com',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_002',
          customerCode: 'CUST002',
          firstName: 'Sarah',
          lastName: 'Johnson',
          email: 'sarah.j@email.com',
          phoneNumber: '+1-555-0202',
          status: CustomerStatus.active,
          source: CustomerSource.walkIn,
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          updatedAt: DateTime.now(),
          address: '456 Oak Ave',
          city: 'Somewhere',
          state: 'NY',
          zipCode: '67890',
          country: 'USA',
          dateOfBirth: DateTime(1990, 7, 22),
          loyaltyTier: LoyaltyTier.silver,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
          totalSpent: 850.00,
          notes: 'Has multiple pets, very caring owner',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_002',
              name: 'Mike Johnson',
              relationship: 'Husband',
              phoneNumber: '+1-555-0203',
              customerId: 'cust_002',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_003',
          customerCode: 'CUST003',
          firstName: 'Michael',
          lastName: 'Brown',
          email: 'mike.brown@email.com',
          phoneNumber: '+1-555-0303',
          status: CustomerStatus.active,
          source: CustomerSource.referral,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
          address: '789 Pine St',
          city: 'Elsewhere',
          state: 'TX',
          zipCode: '11111',
          country: 'USA',
          dateOfBirth: DateTime(1978, 11, 8),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
          totalSpent: 450.00,
          notes: 'New customer, referred by Sarah Johnson',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_003',
              name: 'Lisa Brown',
              relationship: 'Wife',
              phoneNumber: '+1-555-0304',
              customerId: 'cust_003',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        // Additional customers for better testing
        Customer(
          id: 'cust_004',
          customerCode: 'CUST004',
          firstName: 'Emily',
          lastName: 'Davis',
          email: 'emily.davis@email.com',
          phoneNumber: '+1-555-0404',
          status: CustomerStatus.active,
          source: CustomerSource.onlineBooking,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
          address: '321 Elm St',
          city: 'Newtown',
          state: 'FL',
          zipCode: '22222',
          country: 'USA',
          dateOfBirth: DateTime(1992, 4, 18),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 21)),
          totalSpent: 320.00,
          notes: 'Loves her cat, very attentive owner',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_004',
              name: 'David Davis',
              relationship: 'Brother',
              phoneNumber: '+1-555-0405',
              customerId: 'cust_004',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_005',
          customerCode: 'CUST005',
          firstName: 'Robert',
          lastName: 'Wilson',
          email: 'rob.wilson@email.com',
          phoneNumber: '+1-555-0505',
          status: CustomerStatus.active,
          source: CustomerSource.walkIn,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
          address: '654 Maple Dr',
          city: 'Oldtown',
          state: 'OH',
          zipCode: '33333',
          country: 'USA',
          dateOfBirth: DateTime(1988, 12, 3),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 28)),
          totalSpent: 180.00,
          notes: 'First-time pet owner, learning quickly',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_005',
              name: 'Jennifer Wilson',
              relationship: 'Sister',
              phoneNumber: '+1-555-0506',
              customerId: 'cust_005',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_006',
          customerCode: 'CUST006',
          firstName: 'Lisa',
          lastName: 'Anderson',
          email: 'lisa.anderson@email.com',
          phoneNumber: '+1-555-0606',
          status: CustomerStatus.active,
          source: CustomerSource.referral,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          address: '987 Cedar Ln',
          city: 'Midtown',
          state: 'WA',
          zipCode: '44444',
          country: 'USA',
          dateOfBirth: DateTime(1983, 6, 25),
          loyaltyTier: LoyaltyTier.silver,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 5)),
          totalSpent: 650.00,
          notes: 'Experienced pet owner, very knowledgeable',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_006',
              name: 'Tom Anderson',
              relationship: 'Husband',
              phoneNumber: '+1-555-0607',
              customerId: 'cust_006',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_007',
          customerCode: 'CUST007',
          firstName: 'James',
          lastName: 'Taylor',
          email: 'james.taylor@email.com',
          phoneNumber: '+1-555-0707',
          status: CustomerStatus.active,
          source: CustomerSource.onlineBooking,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
          address: '147 Birch Rd',
          city: 'Uptown',
          state: 'CO',
          zipCode: '55555',
          country: 'USA',
          dateOfBirth: DateTime(1995, 9, 12),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 2)),
          totalSpent: 95.00,
          notes: 'Young professional, busy schedule',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_007',
              name: 'Amanda Taylor',
              relationship: 'Roommate',
              phoneNumber: '+1-555-0708',
              customerId: 'cust_007',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_008',
          customerCode: 'CUST008',
          firstName: 'Maria',
          lastName: 'Garcia',
          email: 'maria.garcia@email.com',
          phoneNumber: '+1-555-0808',
          status: CustomerStatus.active,
          source: CustomerSource.walkIn,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
          address: '258 Spruce Ave',
          city: 'Downtown',
          state: 'AZ',
          zipCode: '66666',
          country: 'USA',
          dateOfBirth: DateTime(1987, 1, 30),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 1)),
          totalSpent: 45.00,
          notes: 'New customer, very friendly',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_008',
              name: 'Carlos Garcia',
              relationship: 'Brother',
              phoneNumber: '+1-555-0809',
              customerId: 'cust_008',
              isPrimary: true,
            ),
          ],
          isActive: true,
        ),
      ];

      int createdCount = 0;
      for (final customer in customers) {
        try {
          await _customerDao.insert(customer);
          createdCount++;
          print('CustomerDataSeeder: Created customer: ${customer.fullName}');
        } catch (e) {
          print('CustomerDataSeeder: Error creating customer ${customer.fullName}: $e');
        }
      }
      
      print('CustomerDataSeeder: Successfully created $createdCount customers');
      
      // Verify customers were created
      final allCustomers = await _customerDao.getAll();
      print('CustomerDataSeeder: Total customers in database: ${allCustomers.length}');
      
    } catch (e) {
      print('CustomerDataSeeder: Error in _seedCustomers: $e');
      rethrow;
    }
  }

  static Future<void> _seedPets() async {
    // Sample pets
    final pets = [
      Pet(
        id: 'pet_001',
        customerId: 'cust_001',
        customerName: 'John Smith',
        name: 'Whiskers',
        type: PetType.cat,
        breed: 'Persian',
        gender: PetGender.male,
        dateOfBirth: DateTime(2020, 5, 10),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        size: PetSize.small,
        color: 'White',
        weight: 4.5,
        microchipNumber: 'CHIP001234',
        temperament: TemperamentType.calm,
        isActive: true,
      ),
      Pet(
        id: 'pet_002',
        customerId: 'cust_001',
        customerName: 'John Smith',
        name: 'Shadow',
        type: PetType.cat,
        breed: 'Maine Coon',
        gender: PetGender.female,
        dateOfBirth: DateTime(2019, 8, 15),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        size: PetSize.medium,
        color: 'Black',
        weight: 6.2,
        microchipNumber: 'CHIP001235',
        temperament: TemperamentType.playful,
        isActive: true,
      ),
      Pet(
        id: 'pet_003',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        name: 'Buddy',
        type: PetType.dog,
        breed: 'Golden Retriever',
        gender: PetGender.male,
        dateOfBirth: DateTime(2018, 3, 20),
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
        size: PetSize.large,
        color: 'Golden',
        weight: 28.5,
        microchipNumber: 'CHIP001236',
        temperament: TemperamentType.friendly,
        isActive: true,
      ),
      Pet(
        id: 'pet_004',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        name: 'Luna',
        type: PetType.cat,
        breed: 'Siamese',
        gender: PetGender.female,
        dateOfBirth: DateTime(2021, 1, 12),
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
        size: PetSize.small,
        color: 'Cream',
        weight: 3.8,
        microchipNumber: 'CHIP001237',
        temperament: TemperamentType.shy,
        isActive: true,
      ),
      Pet(
        id: 'pet_005',
        customerId: 'cust_003',
        customerName: 'Michael Brown',
        name: 'Max',
        type: PetType.dog,
        breed: 'Labrador',
        gender: PetGender.male,
        dateOfBirth: DateTime(2020, 9, 5),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
        size: PetSize.large,
        color: 'Black',
        weight: 32.0,
        microchipNumber: 'CHIP001238',
        temperament: TemperamentType.playful,
        isActive: true,
      ),
    ];

    for (final pet in pets) {
      await _petDao.insert(pet);
    }
  }

  static Future<void> _seedVaccinations() async {
    // Sample vaccinations
    final vaccinations = [
      Vaccination(
        id: 'vac_001',
        petId: 'pet_001',
        petName: 'Whiskers',
        customerId: 'cust_001',
        customerName: 'John Smith',
        type: VaccinationType.fvrcp,
        name: 'FVRCP',
        administeredDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        administeredBy: 'Dr. Sarah Wilson',
        clinicName: 'Anytown Animal Clinic',
        status: VaccinationStatus.upToDate,
        batchNumber: 'LOT2024001',
        notes: 'Annual vaccination',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Vaccination(
        id: 'vac_002',
        petId: 'pet_001',
        petName: 'Whiskers',
        customerId: 'cust_001',
        customerName: 'John Smith',
        type: VaccinationType.rabies,
        name: 'Rabies',
        administeredDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        administeredBy: 'Dr. Sarah Wilson',
        clinicName: 'Anytown Animal Clinic',
        status: VaccinationStatus.upToDate,
        batchNumber: 'LOT2024002',
        notes: 'Annual vaccination',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Vaccination(
        id: 'vac_003',
        petId: 'pet_003',
        petName: 'Buddy',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        type: VaccinationType.dhpp,
        name: 'DHPP',
        administeredDate: DateTime.now().subtract(const Duration(days: 45)),
        expiryDate: DateTime.now().add(const Duration(days: 320)),
        administeredBy: 'Dr. Michael Chen',
        clinicName: 'Somewhere Vet Hospital',
        status: VaccinationStatus.upToDate,
        batchNumber: 'LOT2024003',
        notes: 'Annual vaccination',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
      Vaccination(
        id: 'vac_004',
        petId: 'pet_003',
        petName: 'Buddy',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        type: VaccinationType.rabies,
        name: 'Rabies',
        administeredDate: DateTime.now().subtract(const Duration(days: 45)),
        expiryDate: DateTime.now().add(const Duration(days: 320)),
        administeredBy: 'Dr. Michael Chen',
        clinicName: 'Somewhere Vet Hospital',
        status: VaccinationStatus.upToDate,
        batchNumber: 'LOT2024004',
        notes: 'Annual vaccination',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final vaccination in vaccinations) {
      await _vaccinationDao.create(vaccination);
    }
  }

  static Future<void> _seedWaivers() async {
    // Sample waivers
    final waivers = [
      Waiver(
        id: 'wav_001',
        customerId: 'cust_001',
        customerName: 'John Smith',
        type: WaiverType.boardingConsent,
        title: 'Standard Boarding Waiver',
        content: 'I agree to the terms and conditions of boarding my pet...',
        status: WaiverStatus.signed,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        signedDate: DateTime.now().subtract(const Duration(days: 365)),
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        notes: 'Standard boarding agreement',
        updatedAt: DateTime.now(),
      ),
      Waiver(
        id: 'wav_002',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        type: WaiverType.groomingConsent,
        title: 'Grooming Services Waiver',
        content: 'I agree to the terms and conditions of grooming services...',
        status: WaiverStatus.signed,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        signedDate: DateTime.now().subtract(const Duration(days: 180)),
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        notes: 'Grooming services agreement',
        updatedAt: DateTime.now(),
      ),
    ];

    for (final waiver in waivers) {
      await _waiverDao.create(waiver);
    }
  }

  static Future<void> _seedIncidents() async {
    // Sample incidents
    final incidents = [
      Incident(
        id: 'inc_001',
        customerId: 'cust_002',
        customerName: 'Sarah Johnson',
        petId: 'pet_003',
        petName: 'Buddy',
        type: IncidentType.injury,
        severity: IncidentSeverity.minor,
        status: IncidentStatus.resolved,
        title: 'Minor Paw Injury',
        description: 'Small scratch on paw during playtime',
        reportedDate: DateTime.now().subtract(const Duration(days: 10)),
        reportedBy: 'Staff Member',
        occurredDate: DateTime.now().subtract(const Duration(days: 10)),
        location: 'Play area',
        actionsTaken: 'Cleaned and bandaged',
        followUpRequired: 'None',
        notes: 'Pet was playing with other dogs, minor incident',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final incident in incidents) {
      await _incidentDao.create(incident);
    }
  }
}
