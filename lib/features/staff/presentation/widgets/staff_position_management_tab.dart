import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_position.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/staff_position_service.dart';
import 'package:cat_hotel_pos/core/services/staff_position_dao.dart';

class StaffPositionManagementTab extends ConsumerStatefulWidget {
  const StaffPositionManagementTab({super.key});

  @override
  ConsumerState<StaffPositionManagementTab> createState() => _StaffPositionManagementTabState();
}

class _StaffPositionManagementTabState extends ConsumerState<StaffPositionManagementTab> {
  final StaffPositionService _positionService = StaffPositionService(StaffPositionDao());
  List<StaffPosition> _positions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final positions = await _positionService.getAllPositions();
      
      setState(() {
        _positions = positions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading positions: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple[50]!,
                Colors.indigo[50]!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 32,
                    color: Colors.purple[700],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Position Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Design and manage your company\'s organizational structure',
                          style: TextStyle(
                            color: Colors.purple[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePositionDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Position'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showPositionTemplatesDialog(context),
                    icon: const Icon(Icons.view_list),
                    label: const Text('Use Templates'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[600],
                      side: BorderSide(color: Colors.purple[600]!),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _validateOrgChart(context),
                    icon: const Icon(Icons.verified),
                    label: const Text('Validate Chart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo[600],
                      side: BorderSide(color: Colors.indigo[600]!),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget()
                  : _buildPositionsList(),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading positions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPositions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    if (_positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No positions defined',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first position to start building your org chart',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreatePositionDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Group positions by hierarchy level
    final groupedPositions = <int, List<StaffPosition>>{};
    for (final position in _positions) {
      if (!groupedPositions.containsKey(position.hierarchyLevel)) {
        groupedPositions[position.hierarchyLevel] = [];
      }
      groupedPositions[position.hierarchyLevel]!.add(position);
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
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.work_outline, color: Colors.purple[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POSITION HIERARCHY',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${_positions.length} position${_positions.length != 1 ? 's' : ''} across ${groupedPositions.length} level${groupedPositions.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.purple[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Hierarchy Tree
          _buildHierarchyTree(context, groupedPositions),
        ],
      ),
    );
  }

  Widget _buildHierarchyTree(BuildContext context, Map<int, List<StaffPosition>> groupedPositions) {
    final sortedLevels = groupedPositions.keys.toList()..sort();
    
    return _buildTreeLevel(context, sortedLevels, 0, null, groupedPositions);
  }

  Widget _buildTreeLevel(BuildContext context, List<int> levels, int currentLevel, String? parentId, Map<int, List<StaffPosition>> groupedPositions) {
    if (currentLevel >= levels.length) return const SizedBox.shrink();
    
    final level = levels[currentLevel];
    final positions = groupedPositions[level] ?? [];
    
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
          _buildTreeLevel(context, levels, currentLevel + 1, position.id, groupedPositions)
        ),
      ],
    );
  }

  Widget _buildLevelRow(BuildContext context, List<StaffPosition> positions, int level) {
    final hierarchyLevel = HierarchyLevel.fromLevel(level);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: positions.map((position) => 
        _buildPositionNode(context, position, hierarchyLevel)
      ).toList(),
    );
  }

  Widget _buildPositionNode(BuildContext context, StaffPosition position, HierarchyLevel hierarchyLevel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Position Icon
          _buildPositionIcon(position, hierarchyLevel),
          
          const SizedBox(height: 8),
          
          // Position Card
          _buildHierarchyPositionCard(context, position, hierarchyLevel),
        ],
      ),
    );
  }

  Widget _buildPositionIcon(StaffPosition position, HierarchyLevel hierarchyLevel) {
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
  }

  Widget _buildConnections(BuildContext context, List<StaffPosition> positions) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 30),
      painter: ConnectionPainter(positions.length),
    );
  }

  Widget _buildHierarchyPositionCard(BuildContext context, StaffPosition position, HierarchyLevel hierarchyLevel) {
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
          
          // Description
          if (position.description.isNotEmpty) ...[
            Text(
              position.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          
          // Department
          if (position.department != null) ...[
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
          
          // Base Salary
          if (position.baseSalary != null) ...[
            const SizedBox(height: 8),
            Text(
              'RM ${position.baseSalary!.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHierarchyLevel(int level, List<StaffPosition> positions, HierarchyLevel hierarchyLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level Header
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hierarchyLevel.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hierarchyLevel.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getLevelIcon(level),
                color: hierarchyLevel.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hierarchyLevel.displayName,
                      style: TextStyle(
                        color: hierarchyLevel.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Level $level • ${positions.length} position${positions.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: hierarchyLevel.color.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Positions in this level
        ...positions.map((position) => _buildPositionCard(position, hierarchyLevel)),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPositionCard(StaffPosition position, HierarchyLevel hierarchyLevel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: hierarchyLevel.color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: hierarchyLevel.color,
          child: Icon(
            _getLevelIcon(position.hierarchyLevel),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                position.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hierarchyLevel.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'L${position.hierarchyLevel}',
                style: TextStyle(
                  color: hierarchyLevel.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (position.description.isNotEmpty) ...[
              Text(
                position.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (position.department != null) ...[
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    position.department!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                ],
                if (position.baseSalary != null) ...[
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'RM ${position.baseSalary!.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (position.permissions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: position.permissions.take(3).map((permission) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      permission,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              if (position.permissions.length > 3)
                Text(
                  '+${position.permissions.length - 3} more permissions',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handlePositionAction(value, position),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.workspace_premium;
      case 1:
        return Icons.star;
      case 2:
        return Icons.leaderboard;
      case 3:
        return Icons.manage_accounts;
      case 4:
        return Icons.supervisor_account;
      case 5:
        return Icons.verified_user;
      case 6:
        return Icons.person;
      case 7:
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  void _handlePositionAction(String action, StaffPosition position) {
    switch (action) {
      case 'edit':
        _showEditPositionDialog(context, position);
        break;
      case 'delete':
        _showDeletePositionDialog(context, position);
        break;
    }
  }

  void _showCreatePositionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreatePositionDialog(
        onPositionCreated: (position) {
          _loadPositions(); // Reload positions after creation
        },
      ),
    );
  }

  void _showEditPositionDialog(BuildContext context, StaffPosition position) {
    showDialog(
      context: context,
      builder: (context) => _EditPositionDialog(position: position),
    );
  }

  void _showDeletePositionDialog(BuildContext context, StaffPosition position) {
    showDialog(
      context: context,
      builder: (context) => _DeletePositionDialog(position: position),
    );
  }

  void _showPositionTemplatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PositionTemplatesDialog(
        onTemplatesApplied: (positions) {
          _loadPositions(); // Reload positions after applying template
        },
      ),
    );
  }


  Future<void> _validateOrgChart(BuildContext context) async {
    try {
      final errors = await _positionService.validateOrgChart();
      if (errors.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Organizational chart is valid!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Validation Errors'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errors.map((error) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(error)),
                      ],
                    ),
                  ),
                ).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating org chart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Dialog classes
class _CreatePositionDialog extends StatefulWidget {
  final Function(StaffPosition) onPositionCreated;

  const _CreatePositionDialog({required this.onPositionCreated});

  @override
  State<_CreatePositionDialog> createState() => _CreatePositionDialogState();
}

class _CreatePositionDialogState extends State<_CreatePositionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _salaryController = TextEditingController();
  
  int _selectedHierarchyLevel = 0;
  String? _selectedReportsToId;
  List<String> _selectedPermissions = [];
  
  List<StaffPosition> _availablePositions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailablePositions();
  }

  Future<void> _loadAvailablePositions() async {
    try {
      final positionService = StaffPositionService(StaffPositionDao());
      final positions = await positionService.getAllPositions();
      setState(() {
        _availablePositions = positions;
      });
    } catch (e) {
      print('Error loading positions: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Position'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Position Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a position title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Hierarchy Level
                DropdownButtonFormField<int>(
                  value: _selectedHierarchyLevel,
                  decoration: const InputDecoration(
                    labelText: 'Hierarchy Level',
                    border: OutlineInputBorder(),
                  ),
                  items: HierarchyLevel.values.map((level) => DropdownMenuItem(
                    value: level.level,
                    child: Text('${level.displayName} (L${level.level})'),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHierarchyLevel = value!;
                      _selectedReportsToId = null; // Reset reports to when level changes
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Reports To
                if (_selectedHierarchyLevel > 0) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedReportsToId,
                    decoration: const InputDecoration(
                      labelText: 'Reports To',
                      border: OutlineInputBorder(),
                    ),
                    items: _availablePositions
                        .where((p) => p.hierarchyLevel < _selectedHierarchyLevel)
                        .map((position) => DropdownMenuItem(
                          value: position.id,
                          child: Text('${position.title} (L${position.hierarchyLevel})'),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReportsToId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Base Salary
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Base Salary (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: 'RM ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Permissions
                const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _getAvailablePermissions().map((permission) => 
                    FilterChip(
                      label: Text(permission),
                      selected: _selectedPermissions.contains(permission),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPermissions.add(permission);
                          } else {
                            _selectedPermissions.remove(permission);
                          }
                        });
                      },
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPosition,
          child: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Create Position'),
        ),
      ],
    );
  }

  List<String> _getAvailablePermissions() {
    return [
      'all',
      'manage_staff',
      'manage_finances',
      'manage_operations',
      'manage_department',
      'manage_team',
      'view_reports',
      'train_staff',
      'basic_access',
    ];
  }

  Future<void> _createPosition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final positionService = StaffPositionService(StaffPositionDao());
      final position = await positionService.createPosition(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        hierarchyLevel: _selectedHierarchyLevel,
        reportsToId: _selectedReportsToId,
        permissions: _selectedPermissions,
        baseSalary: _salaryController.text.isNotEmpty 
          ? double.tryParse(_salaryController.text) 
          : null,
        department: _departmentController.text.trim().isNotEmpty 
          ? _departmentController.text.trim() 
          : null,
      );

      widget.onPositionCreated(position);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating position: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _EditPositionDialog extends StatelessWidget {
  final StaffPosition position;

  const _EditPositionDialog({required this.position});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${position.title}'),
      content: Text('Position editing dialog will be implemented here.'),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: null,
          child: Text('Update'),
        ),
      ],
    );
  }
}

class _DeletePositionDialog extends StatelessWidget {
  final StaffPosition position;

  const _DeletePositionDialog({required this.position});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${position.title}'),
      content: Text('Are you sure you want to delete this position?'),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete'),
        ),
      ],
    );
  }
}

class _PositionTemplatesDialog extends StatefulWidget {
  final Function(List<StaffPosition>) onTemplatesApplied;

  const _PositionTemplatesDialog({required this.onTemplatesApplied});

  @override
  State<_PositionTemplatesDialog> createState() => _PositionTemplatesDialogState();
}

class _PositionTemplatesDialogState extends State<_PositionTemplatesDialog> {
  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Small Business Structure',
      'description': 'Basic structure for small businesses with 5-10 employees',
      'positions': [
        {
          'title': 'Business Owner',
          'description': 'Ultimate decision maker and company owner',
          'hierarchyLevel': 0,
          'reportsToId': null,
          'permissions': ['all'],
          'baseSalary': null,
          'department': 'Executive',
        },
        {
          'title': 'Manager',
          'description': 'Oversees daily operations and reports to business owner',
          'hierarchyLevel': 1,
          'reportsToId': null,
          'permissions': ['manage_operations', 'manage_staff', 'view_reports'],
          'baseSalary': null,
          'department': 'Management',
        },
        {
          'title': 'Senior Staff',
          'description': 'Experienced staff member with leadership responsibilities',
          'hierarchyLevel': 2,
          'reportsToId': null,
          'permissions': ['view_reports', 'train_staff'],
          'baseSalary': null,
          'department': null,
        },
        {
          'title': 'Staff Member',
          'description': 'Regular staff member performing assigned duties',
          'hierarchyLevel': 3,
          'reportsToId': null,
          'permissions': ['basic_access'],
          'baseSalary': null,
          'department': null,
        },
      ],
    },
    {
      'name': 'Restaurant Structure',
      'description': 'Typical structure for restaurants and food service businesses',
      'positions': [
        {
          'title': 'Restaurant Owner',
          'description': 'Business owner and ultimate decision maker',
          'hierarchyLevel': 0,
          'reportsToId': null,
          'permissions': ['all'],
          'baseSalary': null,
          'department': 'Executive',
        },
        {
          'title': 'General Manager',
          'description': 'Oversees all restaurant operations',
          'hierarchyLevel': 1,
          'reportsToId': null,
          'permissions': ['manage_staff', 'manage_finances', 'manage_operations'],
          'baseSalary': null,
          'department': 'Management',
        },
        {
          'title': 'Kitchen Manager',
          'description': 'Manages kitchen operations and staff',
          'hierarchyLevel': 2,
          'reportsToId': null,
          'permissions': ['manage_operations', 'manage_staff'],
          'baseSalary': null,
          'department': 'Kitchen',
        },
        {
          'title': 'Front of House Manager',
          'description': 'Manages customer service and front operations',
          'hierarchyLevel': 2,
          'reportsToId': null,
          'permissions': ['manage_operations', 'manage_staff'],
          'baseSalary': null,
          'department': 'Front of House',
        },
        {
          'title': 'Chef',
          'description': 'Head chef responsible for menu and food quality',
          'hierarchyLevel': 3,
          'reportsToId': null,
          'permissions': ['manage_operations', 'view_reports'],
          'baseSalary': null,
          'department': 'Kitchen',
        },
        {
          'title': 'Server',
          'description': 'Customer service staff member',
          'hierarchyLevel': 4,
          'reportsToId': null,
          'permissions': ['basic_access'],
          'baseSalary': null,
          'department': 'Front of House',
        },
        {
          'title': 'Cook',
          'description': 'Kitchen staff member preparing food',
          'hierarchyLevel': 4,
          'reportsToId': null,
          'permissions': ['basic_access'],
          'baseSalary': null,
          'department': 'Kitchen',
        },
      ],
    },
    {
      'name': 'Retail Store Structure',
      'description': 'Structure for retail stores and shops',
      'positions': [
        {
          'title': 'Store Owner',
          'description': 'Business owner and ultimate decision maker',
          'hierarchyLevel': 0,
          'reportsToId': null,
          'permissions': ['all'],
          'baseSalary': null,
          'department': 'Executive',
        },
        {
          'title': 'Store Manager',
          'description': 'Manages daily store operations',
          'hierarchyLevel': 1,
          'reportsToId': null,
          'permissions': ['manage_staff', 'manage_finances', 'manage_operations'],
          'baseSalary': null,
          'department': 'Management',
        },
        {
          'title': 'Assistant Manager',
          'description': 'Assists store manager with operations',
          'hierarchyLevel': 2,
          'reportsToId': null,
          'permissions': ['manage_operations', 'manage_staff'],
          'baseSalary': null,
          'department': 'Management',
        },
        {
          'title': 'Department Head',
          'description': 'Manages specific store department',
          'hierarchyLevel': 3,
          'reportsToId': null,
          'permissions': ['manage_department', 'view_reports'],
          'baseSalary': null,
          'department': null,
        },
        {
          'title': 'Sales Associate',
          'description': 'Customer service and sales staff',
          'hierarchyLevel': 4,
          'reportsToId': null,
          'permissions': ['basic_access'],
          'baseSalary': null,
          'department': null,
        },
        {
          'title': 'Cashier',
          'description': 'Handles transactions and customer checkout',
          'hierarchyLevel': 4,
          'reportsToId': null,
          'permissions': ['basic_access'],
          'baseSalary': null,
          'department': null,
        },
      ],
    },
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Position Templates'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a template to quickly set up your organizational structure:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Icon(
                          Icons.business,
                          color: Colors.purple[700],
                        ),
                      ),
                      title: Text(
                        template['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(template['description']),
                          const SizedBox(height: 8),
                          Text(
                            '${(template['positions'] as List).length} positions',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: _isLoading ? null : () => _applyTemplate(template),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Apply'),
                      ),
                      onTap: () => _showTemplateDetails(template),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showTemplateDetails(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${template['name']} - Details'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Positions in this template:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: (template['positions'] as List).length,
                  itemBuilder: (context, index) {
                    final position = (template['positions'] as List)[index];
                    final hierarchyLevel = HierarchyLevel.fromLevel(position['hierarchyLevel']);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hierarchyLevel.color.withOpacity(0.2),
                          child: Icon(
                            _getLevelIcon(position['hierarchyLevel']),
                            color: hierarchyLevel.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          position['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(position['description']),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hierarchyLevel.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'L${position['hierarchyLevel']}',
                            style: TextStyle(
                              color: hierarchyLevel.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyTemplate(template);
            },
            child: const Text('Apply Template'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTemplate(Map<String, dynamic> template) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final positionService = StaffPositionService(StaffPositionDao());
      final List<StaffPosition> createdPositions = [];
      final Map<int, String> levelToPositionId = {}; // Track position IDs by level

      // Create positions in order (highest level first)
      final positions = (template['positions'] as List)
          .cast<Map<String, dynamic>>()
          ..sort((a, b) => a['hierarchyLevel'].compareTo(b['hierarchyLevel']));

      for (final positionData in positions) {
        // Determine the reportsToId based on hierarchy
        String? reportsToId;
        if (positionData['hierarchyLevel'] > 0) {
          // Find the position at the next higher level
          for (int level = positionData['hierarchyLevel'] - 1; level >= 0; level--) {
            if (levelToPositionId.containsKey(level)) {
              reportsToId = levelToPositionId[level];
              break;
            }
          }
        }

        final position = await positionService.createPosition(
          title: positionData['title'],
          description: positionData['description'],
          hierarchyLevel: positionData['hierarchyLevel'],
          reportsToId: reportsToId,
          permissions: List<String>.from(positionData['permissions']),
          baseSalary: positionData['baseSalary'],
          department: positionData['department'],
        );
        createdPositions.add(position);
        // Store the position ID for this level
        levelToPositionId[positionData['hierarchyLevel']] = position.id;
      }

      widget.onTemplatesApplied(createdPositions);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template['name']} template applied successfully! ${createdPositions.length} positions created.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.workspace_premium;
      case 1:
        return Icons.star;
      case 2:
        return Icons.leaderboard;
      case 3:
        return Icons.manage_accounts;
      case 4:
        return Icons.supervisor_account;
      case 5:
        return Icons.verified_user;
      case 6:
        return Icons.person;
      case 7:
        return Icons.school;
      default:
        return Icons.person;
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
