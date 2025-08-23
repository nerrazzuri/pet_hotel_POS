import 'package:flutter/material.dart';
import '../../../../core/services/crm_dao.dart';
import '../../domain/entities/communication_template.dart';

class CommunicationTemplatesTab extends StatefulWidget {
  final CrmDao crmDao;

  const CommunicationTemplatesTab({super.key, required this.crmDao});

  @override
  State<CommunicationTemplatesTab> createState() => _CommunicationTemplatesTabState();
}

class _CommunicationTemplatesTabState extends State<CommunicationTemplatesTab> {
  List<CommunicationTemplate> _templates = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TemplateType? _selectedType;
  TemplateCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await widget.crmDao.getAllTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
  }

  List<CommunicationTemplate> get _filteredTemplates {
    return _templates.where((template) {
      final matchesSearch = template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || template.type == _selectedType;
      final matchesCategory = _selectedCategory == null || template.category == _selectedCategory;
      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _filteredTemplates.isEmpty
              ? const Center(child: Text('No templates found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search templates',
              hintText: 'Search by name or description',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TemplateType>(
                  decoration: const InputDecoration(
                    labelText: 'Template Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...TemplateType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getTemplateTypeDisplay(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<TemplateCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...TemplateCategory.values.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(_getTemplateCategoryDisplay(category)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(CommunicationTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              _getTemplateTypeIcon(template.type),
              color: _getTemplateTypeColor(template.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    template.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: template.isActive,
              onChanged: (value) => _toggleTemplateStatus(template),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateInfo('Type', _getTemplateTypeDisplay(template.type)),
                _buildTemplateInfo('Category', _getTemplateCategoryDisplay(template.category)),
                _buildTemplateInfo('Subject', template.subject),
                _buildTemplateInfo('Content', template.content),
                _buildTemplateInfo('Variables', '${template.variables.length} variables'),
                _buildTemplateInfo('Created By', template.createdBy),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTemplate(template),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _duplicateTemplate(template),
                        icon: const Icon(Icons.copy),
                        label: const Text('Duplicate'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteTemplate(template),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getTemplateTypeIcon(TemplateType type) {
    switch (type) {
      case TemplateType.email:
        return Icons.email;
      case TemplateType.sms:
        return Icons.sms;
      case TemplateType.whatsapp:
        return Icons.message;
      case TemplateType.push:
        return Icons.notifications;
    }
  }

  Color _getTemplateTypeColor(TemplateType type) {
    switch (type) {
      case TemplateType.email:
        return Colors.blue;
      case TemplateType.sms:
        return Colors.green;
      case TemplateType.whatsapp:
        return Colors.green;
      case TemplateType.push:
        return Colors.orange;
    }
  }

  String _getTemplateTypeDisplay(TemplateType type) {
    switch (type) {
      case TemplateType.email:
        return 'Email';
      case TemplateType.sms:
        return 'SMS';
      case TemplateType.whatsapp:
        return 'WhatsApp';
      case TemplateType.push:
        return 'Push Notification';
    }
  }

  String _getTemplateCategoryDisplay(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.booking:
        return 'Booking';
      case TemplateCategory.vaccination:
        return 'Vaccination';
      case TemplateCategory.loyalty:
        return 'Loyalty';
      case TemplateCategory.marketing:
        return 'Marketing';
      case TemplateCategory.reminder:
        return 'Reminder';
      case TemplateCategory.notification:
        return 'Notification';
    }
  }

  void _editTemplate(CommunicationTemplate template) {
    // TODO: Implement edit template dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit template: ${template.name}')),
    );
  }

  void _duplicateTemplate(CommunicationTemplate template) {
    // TODO: Implement duplicate template
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicate template: ${template.name}')),
    );
  }

  void _deleteTemplate(CommunicationTemplate template) {
    // TODO: Implement delete template confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete template: ${template.name}')),
    );
  }

  void _toggleTemplateStatus(CommunicationTemplate template) {
    // TODO: Implement toggle template status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          template.isActive ? 'Deactivating template' : 'Activating template',
        ),
      ),
    );
  }
}
