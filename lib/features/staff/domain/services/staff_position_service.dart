import 'package:cat_hotel_pos/features/staff/domain/entities/staff_position.dart';
import 'package:cat_hotel_pos/core/services/staff_position_dao.dart';

class StaffPositionService {
  final StaffPositionDao _positionDao;

  StaffPositionService(this._positionDao);

  /// Get all active positions
  Future<List<StaffPosition>> getAllPositions() async {
    return await _positionDao.getAllPositions();
  }

  /// Get position by ID
  Future<StaffPosition?> getPositionById(String id) async {
    return await _positionDao.getPositionById(id);
  }

  /// Create a new position
  Future<StaffPosition> createPosition({
    required String title,
    required String description,
    required int hierarchyLevel,
    String? reportsToId,
    List<String> permissions = const [],
    double? baseSalary,
    String? department,
  }) async {
    final position = StaffPosition.create(
      title: title,
      description: description,
      hierarchyLevel: hierarchyLevel,
      reportsToId: reportsToId,
      permissions: permissions,
      baseSalary: baseSalary,
      department: department,
    );

    return await _positionDao.createPosition(position);
  }

  /// Update an existing position
  Future<StaffPosition> updatePosition(StaffPosition position) async {
    final updatedPosition = position.copyWith(updatedAt: DateTime.now());
    return await _positionDao.updatePosition(updatedPosition);
  }

  /// Delete a position
  Future<bool> deletePosition(String id) async {
    return await _positionDao.deletePosition(id);
  }

  /// Get positions by hierarchy level
  Future<List<StaffPosition>> getPositionsByLevel(int level) async {
    final allPositions = await getAllPositions();
    return allPositions.where((p) => p.hierarchyLevel == level).toList();
  }

  /// Get positions that report to a specific position
  Future<List<StaffPosition>> getSubordinatePositions(String positionId) async {
    final allPositions = await getAllPositions();
    return allPositions.where((p) => p.reportsToId == positionId).toList();
  }

  /// Get the reporting chain for a position
  Future<List<StaffPosition>> getReportingChain(String positionId) async {
    final chain = <StaffPosition>[];
    var currentPosition = await getPositionById(positionId);
    
    while (currentPosition != null && currentPosition.reportsToId != null) {
      final nextPosition = await getPositionById(currentPosition.reportsToId!);
      if (nextPosition != null) {
        chain.add(nextPosition);
        currentPosition = nextPosition;
      } else {
        break;
      }
    }
    
    return chain.reversed.toList();
  }

  /// Get the org chart structure
  Future<Map<int, List<StaffPosition>>> getOrgChart() async {
    final allPositions = await getAllPositions();
    final chart = <int, List<StaffPosition>>{};
    
    for (final position in allPositions) {
      final level = position.hierarchyLevel;
      if (!chart.containsKey(level)) {
        chart[level] = [];
      }
      chart[level]!.add(position);
    }
    
    // Sort positions within each level by title
    for (final level in chart.keys) {
      chart[level]!.sort((a, b) => a.title.compareTo(b.title));
    }
    
    return chart;
  }

  /// Validate org chart hierarchy
  Future<List<String>> validateOrgChart() async {
    final errors = <String>[];
    final allPositions = await getAllPositions();
    
    // Check for circular references
    for (final position in allPositions) {
      if (position.reportsToId != null) {
        final visited = <String>{};
        String? currentId = position.id;
        
        while (currentId != null) {
          if (visited.contains(currentId)) {
            errors.add('Circular reference detected for position: ${position.title}');
            break;
          }
          
          visited.add(currentId);
          final currentPosition = allPositions.firstWhere(
            (p) => p.id == currentId,
            orElse: () => throw Exception('Position not found: $currentId'),
          );
          
          currentId = currentPosition.reportsToId;
        }
      }
    }
    
    // Check for orphaned positions (positions that report to non-existent positions)
    for (final position in allPositions) {
      if (position.reportsToId != null) {
        final exists = allPositions.any((p) => p.id == position.reportsToId);
        if (!exists) {
          errors.add('Position "${position.title}" reports to non-existent position');
        }
      }
    }
    
    return errors;
  }

  /// Get available reporting options for a new position
  Future<List<StaffPosition>> getAvailableReportingOptions(int hierarchyLevel) async {
    final allPositions = await getAllPositions();
    return allPositions
        .where((p) => p.hierarchyLevel < hierarchyLevel && p.isActive)
        .toList()
      ..sort((a, b) => a.hierarchyLevel.compareTo(b.hierarchyLevel));
  }

  /// Check if user has permission to manage positions
  Future<bool> canManagePositions(String userId) async {
    // This would typically check user permissions
    // For now, return true for business owners and admins
    return true;
  }
}
