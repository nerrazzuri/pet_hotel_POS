import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';

class CustomerSearchSection extends StatefulWidget {
  const CustomerSearchSection({super.key});

  @override
  State<CustomerSearchSection> createState() => _CustomerSearchSectionState();
}

class _CustomerSearchSectionState extends State<CustomerSearchSection> {
  bool _isCustomerLocked = false;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header with Fuzzy Search Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.person_search,
                    color: colorScheme.onPrimaryContainer,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 10,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Fuzzy Search',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Search Row with Customer Info on same row when locked
            Row(
              children: [
                // Customer Name Search with Dropdown Autocomplete
                Expanded(
                  flex: 2,
                  child: Autocomplete<Customer>(
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Search by name...',
                          prefixIcon: Icon(Icons.person, color: colorScheme.primary, size: 16),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    controller.clear();
                                    _customerNameController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                          labelStyle: TextStyle(fontSize: 11),
                        ),
                        style: TextStyle(fontSize: 11),
                        onChanged: (value) {
                          _customerNameController.text = value;
                          setState(() {});
                        },
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const <Customer>[];
                      }
                      
                      try {
                        final customers = await CustomerService().searchCustomers(textEditingValue.text);
                        return customers.where((customer) {
                          final query = textEditingValue.text.toLowerCase();
                          return customer.fullName.toLowerCase().contains(query) ||
                                 customer.firstName.toLowerCase().contains(query) ||
                                 customer.lastName.toLowerCase().contains(query);
                        }).take(5).toList();
                      } catch (e) {
                        return const <Customer>[];
                      }
                    },
                    displayStringForOption: (Customer customer) => customer.fullName,
                    optionsViewBuilder: (context, onSelected, options) {
                      return Material(
                        elevation: 4.0,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final Customer option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    option.firstName.isNotEmpty ? option.firstName[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  option.fullName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                subtitle: Text(
                                  option.phoneNumber.isNotEmpty ? option.phoneNumber : 'No phone',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                onTap: () {
                                  onSelected(option);
                                  _customerNameController.text = option.fullName;
                                  _customerPhoneController.text = option.phoneNumber;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onSelected: (Customer customer) {
                      _customerNameController.text = customer.fullName;
                      _customerPhoneController.text = customer.phoneNumber;
                      setState(() {});
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Phone Number Search with Dropdown Autocomplete
                Expanded(
                  flex: 2,
                  child: Autocomplete<Customer>(
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Search by phone...',
                          prefixIcon: Icon(Icons.phone, color: colorScheme.primary, size: 16),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    controller.clear();
                                    _customerPhoneController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                          labelStyle: TextStyle(fontSize: 11),
                        ),
                        style: TextStyle(fontSize: 11),
                        onChanged: (value) {
                          _customerPhoneController.text = value;
                          setState(() {});
                        },
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const <Customer>[];
                      }
                      
                      try {
                        final customers = await CustomerService().searchCustomers(textEditingValue.text);
                        return customers.where((customer) {
                          final query = textEditingValue.text.toLowerCase();
                          return customer.phoneNumber.toLowerCase().contains(query);
                        }).take(5).toList();
                      } catch (e) {
                        return const <Customer>[];
                      }
                    },
                    displayStringForOption: (Customer customer) => customer.phoneNumber,
                    optionsViewBuilder: (context, onSelected, options) {
                      return Material(
                        elevation: 4.0,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final Customer option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green[100],
                                  child: Icon(
                                    Icons.phone,
                                    size: 12,
                                    color: Colors.green[800],
                                  ),
                                ),
                                title: Text(
                                  option.phoneNumber,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                subtitle: Text(
                                  option.fullName,
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                onTap: () {
                                  onSelected(option);
                                  _customerNameController.text = option.fullName;
                                  _customerPhoneController.text = option.phoneNumber;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onSelected: (Customer customer) {
                      _customerNameController.text = customer.fullName;
                      _customerPhoneController.text = customer.phoneNumber;
                      setState(() {});
                    },
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Customer Lock Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isCustomerLocked,
                      onChanged: (value) {
                        setState(() {
                          _isCustomerLocked = value ?? false;
                        });
                      },
                      activeColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      'Lock',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 12),
                
                // Customer Display (when locked) - on same row
                if (_isCustomerLocked && (_customerNameController.text.isNotEmpty || _customerPhoneController.text.isNotEmpty)) ...[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin,
                            color: colorScheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_customerNameController.text.isNotEmpty)
                                  Text(
                                    _customerNameController.text,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (_customerPhoneController.text.isNotEmpty)
                                  Text(
                                    _customerPhoneController.text,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 9,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isCustomerLocked = false;
                                _customerNameController.clear();
                                _customerPhoneController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.error,
                              size: 12,
                            ),
                            tooltip: 'Remove Customer',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
