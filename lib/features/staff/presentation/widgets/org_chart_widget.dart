import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_position.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';

class OrgChartWidget extends StatelessWidget {
  final Map<int, List<StaffPosition>> orgChart;
  final List<StaffMember> staffMembers;
  final VoidCallback? onPositionTap;
  final VoidCallback? onStaffTap;

  const OrgChartWidget({
    super.key,
    required this.orgChart,
    required this.staffMembers,
    this.onPositionTap,
    this.onStaffTap,
  });

  @override
  Widget build(BuildContext context) {
    if (orgChart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No organizational structure defined',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create positions to build your org chart',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              'COMPANY ORGANIZATION CHART',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Tree-like Organization Chart
          _buildTreeChart(context),
        ],
      ),
    );
  }

  Widget _buildTreeChart(BuildContext context) {
    final sortedLevels = orgChart.keys.toList()..sort();
    
    // Build the tree structure
    return _buildTreeLevel(context, sortedLevels, 0, null);
  }

  Widget _buildTreeLevel(BuildContext context, List<int> levels, int currentLevel, String? parentId) {
    if (currentLevel >= levels.length) return const SizedBox.shrink();
    
    final level = levels[currentLevel];
    final positions = orgChart[level] ?? [];
    
    // Filter positions that report to the current parent
    final filteredPositions = parentId == null 
        ? positions.where((p) => p.reportsToId == null).toList()
        : positions.where((p) => p.reportsToId == parentId).toList();
    
    if (filteredPositions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        // Current level positions
        _buildLevelRow(context, filteredPositions, level),
        
        // Connections to next level
        if (currentLevel < levels.length - 1) ...[
          const SizedBox(height: 30),
          _buildConnections(context, filteredPositions),
          const SizedBox(height: 30),
        ],
        
        // Next level (recursive)
        ...filteredPositions.map((position) => 
          _buildTreeLevel(context, levels, currentLevel + 1, position.id)
        ),
      ],
    );
  }

  Widget _buildLevelRow(BuildContext context, List<StaffPosition> positions, int level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: positions.map((position) => 
        _buildPositionNode(context, position, level)
      ).toList(),
    );
  }

  Widget _buildPositionNode(BuildContext context, StaffPosition position, int level) {
    final staffInPosition = _getStaffInPosition(position);
    final hierarchyLevel = HierarchyLevel.fromLevel(level);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Profile Picture
          _buildProfilePicture(staffInPosition, hierarchyLevel),
          
          const SizedBox(height: 8),
          
          // Position Card
          _buildPositionCard(context, position, staffInPosition, hierarchyLevel),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(List<StaffMember> staff, HierarchyLevel hierarchyLevel) {
    if (staff.isEmpty) {
      // Default profile picture
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hierarchyLevel.color.withOpacity(0.1),
          border: Border.all(color: hierarchyLevel.color, width: 2),
        ),
        child: Icon(
          _getLevelIcon(hierarchyLevel.level),
          color: hierarchyLevel.color,
          size: 30,
        ),
      );
    } else if (staff.length == 1) {
      // Single staff member
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hierarchyLevel.color.withOpacity(0.1),
          border: Border.all(color: hierarchyLevel.color, width: 2),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: hierarchyLevel.color.withOpacity(0.2),
          child: Text(
            staff.first.fullName.split(' ').map((n) => n[0]).join(''),
            style: TextStyle(
              color: hierarchyLevel.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      // Multiple staff members - show count
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hierarchyLevel.color.withOpacity(0.1),
          border: Border.all(color: hierarchyLevel.color, width: 2),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: hierarchyLevel.color.withOpacity(0.2),
          child: Text(
            '${staff.length}',
            style: TextStyle(
              color: hierarchyLevel.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPositionCard(BuildContext context, StaffPosition position, List<StaffMember> staff, HierarchyLevel hierarchyLevel) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hierarchyLevel.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Position Title
          Text(
            position.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: hierarchyLevel.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Staff Members
          if (staff.isNotEmpty) ...[
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...staff.map((member) => 
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Text(
                  member.fullName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ] else ...[
            Text(
              'Vacant',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          // Department
          if (position.department != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hierarchyLevel.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                position.department!,
                style: TextStyle(
                  fontSize: 10,
                  color: hierarchyLevel.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnections(BuildContext context, List<StaffPosition> positions) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 30),
      painter: ConnectionPainter(positions.length),
    );
  }

  List<StaffMember> _getStaffInPosition(StaffPosition position) {
    return staffMembers.where((staff) => 
      staff.position == position.title || 
      (staff.department == position.department && staff.role.displayName == position.title)
    ).toList();
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.workspace_premium; // Business Owner
      case 1:
        return Icons.manage_accounts; // Manager
      case 2:
        return Icons.supervisor_account; // Supervisor
      case 3:
        return Icons.person; // Staff
      default:
        return Icons.person_outline;
    }
  }
}

class ConnectionPainter extends CustomPainter {
  final int nodeCount;
  
  ConnectionPainter(this.nodeCount);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    if (nodeCount <= 1) return;
    
    const nodeWidth = 240.0; // 200 (card width) + 40 (margin)
    final startX = (size.width - (nodeCount * nodeWidth)) / 2 + nodeWidth / 2;
    
    // Draw horizontal line connecting all nodes
    canvas.drawLine(
      Offset(startX, size.height / 2),
      Offset(startX + (nodeCount - 1) * nodeWidth, size.height / 2),
      paint,
    );
    
    // Draw vertical lines from each node
    for (int i = 0; i < nodeCount; i++) {
      final x = startX + i * nodeWidth;
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}