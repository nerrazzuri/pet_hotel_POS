// Functional Pet DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';

class PetDao {
  static final Map<String, Pet> _pets = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample pets
    _pets['pet_001'] = Pet(
      id: 'pet_001',
      customerId: 'cust_001',
      customerName: 'John Doe',
      name: 'Whiskers',
      type: PetType.cat,
      gender: PetGender.male,
      size: PetSize.small,
      dateOfBirth: DateTime(2020, 3, 15),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      breed: 'Persian',
      color: 'White',
      weight: 4.5,
      weightUnit: 'kg',
      microchipNumber: 'CHIP001234',
      isNeutered: true,
      isSpayed: false,
      isVaccinated: true,
      isDewormed: true,
      isFleaTreated: true,
      isTickTreated: true,
      temperament: TemperamentType.friendly,
      temperamentNotes: 'Very friendly and social',
      allergies: ['Dairy products'],
      medications: [],
      specialNeeds: ['Requires daily grooming'],
      behaviorNotes: 'Very friendly and social',
      veterinarianName: 'Dr. Sarah Chen',
      veterinarianPhone: '+60-3-1234-5678',
      isActive: true,
    );

    _pets['pet_002'] = Pet(
      id: 'pet_002',
      customerId: 'cust_002',
      customerName: 'Jane Smith',
      name: 'Shadow',
      type: PetType.cat,
      gender: PetGender.male,
      size: PetSize.medium,
      dateOfBirth: DateTime(2019, 7, 22),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      breed: 'Maine Coon',
      color: 'Black',
      weight: 6.2,
      weightUnit: 'kg',
      microchipNumber: 'CHIP001235',
      isNeutered: true,
      isSpayed: false,
      isVaccinated: true,
      isDewormed: true,
      isFleaTreated: true,
      isTickTreated: true,
      temperament: TemperamentType.independent,
      temperamentNotes: 'Independent but affectionate',
      allergies: [],
      medications: [],
      specialNeeds: ['Loves climbing and high places'],
      behaviorNotes: 'Independent but affectionate',
      veterinarianName: 'Dr. Ahmad Rahman',
      veterinarianPhone: '+60-3-1234-5679',
      isActive: true,
    );

    _pets['pet_003'] = Pet(
      id: 'pet_003',
      customerId: 'cust_003',
      customerName: 'Mike Johnson',
      name: 'Luna',
      type: PetType.cat,
      gender: PetGender.female,
      size: PetSize.small,
      dateOfBirth: DateTime(2021, 1, 10),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      breed: 'Siamese',
      color: 'Cream with dark points',
      weight: 3.8,
      weightUnit: 'kg',
      microchipNumber: 'CHIP001236',
      isNeutered: false,
      isSpayed: true,
      isVaccinated: true,
      isDewormed: true,
      isFleaTreated: true,
      isTickTreated: true,
      temperament: TemperamentType.social,
      temperamentNotes: 'Vocal and talkative',
      allergies: ['Fish'],
      medications: [],
      specialNeeds: ['Sensitive to loud noises'],
      behaviorNotes: 'Vocal and talkative',
      veterinarianName: 'Dr. David Tan',
      veterinarianPhone: '+60-3-1234-5680',
      isActive: true,
    );

    _pets['pet_004'] = Pet(
      id: 'pet_004',
      customerId: 'cust_004',
      customerName: 'Sarah Wilson',
      name: 'Tiger',
      type: PetType.cat,
      gender: PetGender.male,
      size: PetSize.medium,
      dateOfBirth: DateTime(2018, 11, 5),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      breed: 'Tabby',
      color: 'Orange tabby',
      weight: 5.1,
      weightUnit: 'kg',
      microchipNumber: 'CHIP001237',
      isNeutered: true,
      isSpayed: false,
      isVaccinated: false,
      isDewormed: true,
      isFleaTreated: true,
      isTickTreated: true,
      temperament: TemperamentType.calm,
      temperamentNotes: 'Gentle and patient with children',
      allergies: [],
      medications: ['Joint supplement'],
      specialNeeds: ['Arthritis management'],
      behaviorNotes: 'Gentle and patient with children',
      veterinarianName: 'Dr. Lisa Wong',
      veterinarianPhone: '+60-3-1234-5681',
      isActive: true,
    );

    _pets['pet_005'] = Pet(
      id: 'pet_005',
      customerId: 'cust_005',
      customerName: 'David Brown',
      name: 'Mittens',
      type: PetType.cat,
      gender: PetGender.female,
      size: PetSize.small,
      dateOfBirth: DateTime(2022, 5, 18),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      breed: 'Ragdoll',
      color: 'Blue point',
      weight: 4.0,
      weightUnit: 'kg',
      microchipNumber: 'CHIP001238',
      isNeutered: true,
      isSpayed: false,
      isVaccinated: true,
      isDewormed: true,
      isFleaTreated: true,
      isTickTreated: true,
      temperament: TemperamentType.calm,
      temperamentNotes: 'Very relaxed and floppy',
      allergies: [],
      medications: [],
      specialNeeds: ['Loves being held like a baby'],
      behaviorNotes: 'Very relaxed and floppy',
      veterinarianName: 'Dr. Sarah Chen',
      veterinarianPhone: '+60-3-1234-5678',
      isActive: true,
    );

    _initialized = true;
  }

  Future<void> insert(Pet pet) async {
    _initialize();
    _pets[pet.id] = pet;
  }

  Future<Pet?> getById(String id) async {
    _initialize();
    return _pets[id];
  }

  Future<List<Pet>> getByCustomerId(String customerId) async {
    _initialize();
    return _pets.values.where((pet) => pet.customerId == customerId).toList();
  }

  Future<List<Pet>> getAll() async {
    _initialize();
    return _pets.values.toList();
  }

  Future<Pet> update(Pet pet) async {
    _initialize();
    _pets[pet.id] = pet;
    return pet;
  }

  Future<void> delete(String id) async {
    _initialize();
    _pets.remove(id);
  }

  Future<List<Pet>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _pets.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _pets.values.where((pet) =>
      pet.name.toLowerCase().contains(lowercaseQuery) ||
      (pet.breed?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (pet.color?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<Pet>> getByType(PetType type) async {
    _initialize();
    return _pets.values.where((pet) => pet.type == type).toList();
  }

  Future<List<Pet>> getByVaccinationStatus(bool isVaccinated) async {
    _initialize();
    return _pets.values.where((pet) => pet.isVaccinated == isVaccinated).toList();
  }

  Future<int> getTotalPets() async {
    _initialize();
    return _pets.length;
  }

  Future<Map<String, int>> getPetsByType() async {
    _initialize();
    final result = <String, int>{};
    for (final pet in _pets.values) {
      final type = pet.type.name;
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, int>> getPetsByVaccinationStatus() async {
    _initialize();
    final result = <String, int>{};
    for (final pet in _pets.values) {
      final status = pet.isVaccinated == true ? 'vaccinated' : 'not_vaccinated';
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }
}
