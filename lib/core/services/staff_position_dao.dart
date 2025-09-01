import 'package:cat_hotel_pos/features/staff/domain/entities/staff_position.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_position.dart' as entities;

class StaffPositionDao {
  static const String _storageKey = 'staff_positions';
  
  /// Get all positions from storage
  Future<List<StaffPosition>> getAllPositions() async {
    try {
      final data = WebStorageService.getData(_storageKey);
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = data;
      final positions = jsonList
          .map((json) => StaffPosition.fromJson(json as Map<String, dynamic>))
          .where((position) => position.isActive)
          .toList();
      return positions;
    } catch (e) {
      print('DAO: Error getting staff positions: $e');
      return [];
    }
  }

  /// Get position by ID
  Future<StaffPosition?> getPositionById(String id) async {
    try {
      final positions = await getAllPositions();
      return positions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new position
  Future<StaffPosition> createPosition(StaffPosition position) async {
    try {
      final positions = await getAllPositions();
      positions.add(position);
      await _savePositions(positions);
      return position;
    } catch (e) {
      throw Exception('Failed to create position: $e');
    }
  }

  /// Update an existing position
  Future<StaffPosition> updatePosition(StaffPosition position) async {
    try {
      final positions = await getAllPositions();
      final index = positions.indexWhere((p) => p.id == position.id);
      if (index == -1) {
        throw Exception('Position not found');
      }
      
      positions[index] = position;
      await _savePositions(positions);
      return position;
    } catch (e) {
      throw Exception('Failed to update position: $e');
    }
  }

  /// Delete a position
  Future<bool> deletePosition(String id) async {
    try {
      final positions = await getAllPositions();
      final index = positions.indexWhere((p) => p.id == id);
      if (index == -1) {
        return false;
      }
      
      // Soft delete by setting isActive to false
      final updatedPosition = positions[index].copyWith(isActive: false);
      positions[index] = updatedPosition;
      await _savePositions(positions);
      return true;
    } catch (e) {
      throw Exception('Failed to delete position: $e');
    }
  }

  /// Save positions to storage
  Future<void> _savePositions(List<StaffPosition> positions) async {
    try {
      final jsonList = positions.map((p) => p.toJson()).toList();
      WebStorageService.saveData(_storageKey, jsonList);
    } catch (e) {
      throw Exception('Failed to save positions: $e');
    }
  }

  /// Get default positions for new installations
  List<StaffPosition> _getDefaultPositions() {
    return [
      StaffPosition.create(
        title: 'Business Owner',
        description: 'Ultimate decision maker and company owner',
        hierarchyLevel: 0,
        reportsToId: null,
        permissions: ['all'],
        department: 'Executive',
      ),
      StaffPosition.create(
        title: 'General Manager',
        description: 'Oversees all operations and reports to business owner',
        hierarchyLevel: 1,
        reportsToId: null, // Will be set to business owner
        permissions: ['manage_staff', 'manage_finances', 'manage_operations'],
        department: 'Management',
      ),
      StaffPosition.create(
        title: 'Operations Manager',
        description: 'Manages daily operations and reports to general manager',
        hierarchyLevel: 2,
        reportsToId: null, // Will be set to general manager
        permissions: ['manage_operations', 'manage_staff'],
        department: 'Operations',
      ),
      StaffPosition.create(
        title: 'Department Head',
        description: 'Leads a specific department and reports to operations manager',
        hierarchyLevel: 3,
        reportsToId: null, // Will be set to operations manager
        permissions: ['manage_department', 'view_reports'],
        department: null,
      ),
      StaffPosition.create(
        title: 'Team Lead',
        description: 'Leads a team and reports to department head',
        hierarchyLevel: 4,
        reportsToId: null, // Will be set to department head
        permissions: ['manage_team', 'view_reports'],
        department: null,
      ),
      StaffPosition.create(
        title: 'Senior Staff',
        description: 'Experienced staff member with some leadership responsibilities',
        hierarchyLevel: 5,
        reportsToId: null, // Will be set to team lead
        permissions: ['view_reports', 'train_staff'],
        department: null,
      ),
      StaffPosition.create(
        title: 'Staff Member',
        description: 'Regular staff member performing assigned duties',
        hierarchyLevel: 6,
        reportsToId: null, // Will be set to senior staff or team lead
        permissions: ['basic_access'],
        department: null,
      ),
      StaffPosition.create(
        title: 'Trainee',
        description: 'New staff member in training',
        hierarchyLevel: 7,
        reportsToId: null, // Will be set to staff member or team lead
        permissions: ['basic_access'],
        department: null,
      ),
    ];
  }

  /// Get sample positions based on existing staff structure
  List<StaffPosition> _getSamplePositions() {
    return [
      // Level 0 - Business Owner
      StaffPosition.create(
        title: 'Business Owner',
        description: 'Ultimate decision maker and company owner',
        hierarchyLevel: 0,
        reportsToId: null,
        permissions: ['all'],
        department: 'Executive',
      ),
      
      // Level 1 - General Manager
      StaffPosition.create(
        title: 'General Manager',
        description: 'Oversees all operations and reports to business owner',
        hierarchyLevel: 1,
        reportsToId: null, // Will be set to business owner
        permissions: ['manage_staff', 'manage_finances', 'manage_operations'],
        department: 'Management',
      ),
      
      // Level 2 - Department Managers
      StaffPosition.create(
        title: 'Front Office Manager',
        description: 'Manages front office operations including reception and cashier',
        hierarchyLevel: 2,
        reportsToId: null, // Will be set to general manager
        permissions: ['manage_operations', 'manage_staff'],
        department: 'Front Office',
      ),
      StaffPosition.create(
        title: 'Grooming Manager',
        description: 'Manages grooming department and staff',
        hierarchyLevel: 2,
        reportsToId: null, // Will be set to general manager
        permissions: ['manage_operations', 'manage_staff'],
        department: 'Grooming',
      ),
      StaffPosition.create(
        title: 'Housekeeping Manager',
        description: 'Manages housekeeping operations and staff',
        hierarchyLevel: 2,
        reportsToId: null, // Will be set to general manager
        permissions: ['manage_operations', 'manage_staff'],
        department: 'Housekeeping',
      ),
      StaffPosition.create(
        title: 'Medical Director',
        description: 'Oversees medical operations and veterinary services',
        hierarchyLevel: 2,
        reportsToId: null, // Will be set to general manager
        permissions: ['manage_operations', 'manage_staff'],
        department: 'Medical',
      ),
      
      // Level 3 - Senior Staff
      StaffPosition.create(
        title: 'Senior Cashier',
        description: 'Senior cashier with additional responsibilities',
        hierarchyLevel: 3,
        reportsToId: null, // Will be set to front office manager
        permissions: ['view_reports', 'train_staff'],
        department: 'Front Office',
      ),
      StaffPosition.create(
        title: 'Master Groomer',
        description: 'Senior groomer with advanced skills and training responsibilities',
        hierarchyLevel: 3,
        reportsToId: null, // Will be set to grooming manager
        permissions: ['view_reports', 'train_staff'],
        department: 'Grooming',
      ),
      StaffPosition.create(
        title: 'Senior Housekeeper',
        description: 'Senior housekeeper with quality control responsibilities',
        hierarchyLevel: 3,
        reportsToId: null, // Will be set to housekeeping manager
        permissions: ['view_reports', 'train_staff'],
        department: 'Housekeeping',
      ),
      StaffPosition.create(
        title: 'Veterinarian',
        description: 'Licensed veterinarian providing medical care',
        hierarchyLevel: 3,
        reportsToId: null, // Will be set to medical director
        permissions: ['view_reports', 'train_staff'],
        department: 'Medical',
      ),
      
      // Level 4 - Regular Staff
      StaffPosition.create(
        title: 'Receptionist',
        description: 'Front desk receptionist handling customer service',
        hierarchyLevel: 4,
        reportsToId: null, // Will be set to front office manager
        permissions: ['basic_access'],
        department: 'Front Office',
      ),
    ];
  }

  /// Get default positions (for initialization)
  Future<List<StaffPosition>> getDefaultPositions() async {
    return _getDefaultPositions();
  }

  /// Get sample positions based on existing staff
  Future<List<StaffPosition>> getSamplePositions() async {
    return _getSamplePositions();
  }

  /// Initialize default positions if none exist
  Future<void> initializeDefaultPositions() async {
    try {
      final existingPositions = await getAllPositions();
      if (existingPositions.isEmpty) {
        final defaultPositions = _getDefaultPositions();
        await _savePositions(defaultPositions);
      }
    } catch (e) {
      print('Error initializing default positions: $e');
    }
  }

  /// Initialize sample positions based on existing staff structure
  Future<void> initializeSamplePositions() async {
    try {
      final existingPositions = await getAllPositions();
      if (existingPositions.isEmpty) {
        final samplePositions = _getSamplePositions();
        
        // Set up proper reporting relationships
        final Map<int, String> levelToPositionId = {};
        
        for (final position in samplePositions) {
          String? reportsToId;
          if (position.hierarchyLevel > 0) {
            // Find the position at the next higher level
            for (int level = position.hierarchyLevel - 1; level >= 0; level--) {
              if (levelToPositionId.containsKey(level)) {
                reportsToId = levelToPositionId[level];
                break;
              }
            }
          }
          
          // Update the position with the correct reportsToId
          final updatedPosition = position.copyWith(reportsToId: reportsToId);
          levelToPositionId[position.hierarchyLevel] = updatedPosition.id;
        }
        
        await _savePositions(samplePositions);
      }
    } catch (e) {
      print('DAO: Error initializing sample positions: $e');
    }
  }

  /// Clear all positions (for testing/reset)
  Future<void> clearAllPositions() async {
    try {
      WebStorageService.removeData(_storageKey);
    } catch (e) {
      throw Exception('Failed to clear positions: $e');
    }
  }
}
