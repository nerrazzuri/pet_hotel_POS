import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/payroll.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/payroll_service.dart';
import 'package:cat_hotel_pos/core/services/payroll_dao.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class PayrollManagementTab extends ConsumerStatefulWidget {
  const PayrollManagementTab({super.key});

  @override
  ConsumerState<PayrollManagementTab> createState() => _PayrollManagementTabState();
}

class _PayrollManagementTabState extends ConsumerState<PayrollManagementTab> with TickerProviderStateMixin {
  final PayrollService _payrollService = PayrollService(PayrollDao(), TimeTrackingDao());
  final StaffDao _staffDao = StaffDao();
  
  late TabController _tabController;
  List<StaffMember> _staffMembers = [];
  List<PayrollRecord> _payrollRecords = [];
  StaffMember? _selectedStaff;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _staffMembers = await _staffDao.getAll();
      if (_staffMembers.isNotEmpty) {
        _selectedStaff = _staffMembers.first;
        await _loadPayrollRecords();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPayrollRecords() async {
    if (_selectedStaff == null) return;
    
    try {
      _payrollRecords = await _payrollService.getPayrollRecordsByStaffMember(_selectedStaff!.id);
    } catch (e) {
      _showErrorSnackBar('Failed to load payroll records: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStaffSelector(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPayrollRecordsTab(),
                _buildPayrollGenerationTab(),
                _buildPayrollReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.payment, size: 28, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          'Payroll Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStaffSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Staff Member',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StaffMember>(
              value: _selectedStaff,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _staffMembers.map((staff) {
                return DropdownMenuItem(
                  value: staff,
                  child: Text('${staff.fullName} (${staff.employeeId})'),
                );
              }).toList(),
              onChanged: (StaffMember? newValue) async {
                if (newValue != null) {
                  setState(() => _selectedStaff = newValue);
                  await _loadPayrollRecords();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.list), text: 'Payroll Records'),
          Tab(icon: Icon(Icons.add_circle), text: 'Generate Payroll'),
          Tab(icon: Icon(Icons.analytics), text: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildPayrollRecordsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payroll Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _payrollRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No payroll records found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _payrollRecords.length,
                      itemBuilder: (context, index) {
                        final record = _payrollRecords[index];
                        return _buildPayrollRecordCard(record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollRecordCard(PayrollRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.status.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'RM ${record.netPay.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${_formatDate(record.payPeriodStart)} - ${_formatDate(record.payPeriodEnd)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPayrollDetail('Basic Salary', 'RM ${record.basicSalary.toStringAsFixed(2)}', Colors.blue),
                ),
                Expanded(
                  child: _buildPayrollDetail('Overtime', 'RM ${record.overtimePay.toStringAsFixed(2)}', Colors.orange),
                ),
                Expanded(
                  child: _buildPayrollDetail('Allowances', 'RM ${record.allowances.toStringAsFixed(2)}', Colors.green),
                ),
                Expanded(
                  child: _buildPayrollDetail('Deductions', 'RM ${record.deductions.toStringAsFixed(2)}', Colors.red),
                ),
              ],
            ),
            if (record.status == PayrollStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approvePayroll(record.id),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPayStub(record.id),
                      icon: const Icon(Icons.receipt, color: Colors.white),
                      label: const Text('View Pay Stub', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (record.status == PayrollStatus.approved) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _markAsPaid(record.id),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('Mark as Paid', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollGenerationTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Payroll',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Generate New Payroll',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a staff member and click the button below to generate payroll',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _selectedStaff != null ? _showGeneratePayrollDialog : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Generate Payroll'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollReportsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _selectedStaff != null 
          ? _payrollService.getPayrollStatistics(
              staffMemberId: _selectedStaff!.id,
              year: DateTime.now().year,
            )
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payroll Statistics ${DateTime.now().year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'Total Basic Salary',
                        Icons.account_balance_wallet,
                        Colors.blue,
                        'RM ${data['totalBasicSalary'].toStringAsFixed(2)}',
                      ),
                      _buildStatCard(
                        'Total Overtime',
                        Icons.schedule,
                        Colors.orange,
                        'RM ${data['totalOvertimePay'].toStringAsFixed(2)}',
                      ),
                      _buildStatCard(
                        'Total Allowances',
                        Icons.add_circle,
                        Colors.green,
                        'RM ${data['totalAllowances'].toStringAsFixed(2)}',
                      ),
                      _buildStatCard(
                        'Total Deductions',
                        Icons.remove_circle,
                        Colors.red,
                        'RM ${data['totalDeductions'].toStringAsFixed(2)}',
                      ),
                      _buildStatCard(
                        'Gross Pay',
                        Icons.trending_up,
                        Colors.purple,
                        'RM ${data['totalGrossPay'].toStringAsFixed(2)}',
                      ),
                      _buildStatCard(
                        'Net Pay',
                        Icons.payment,
                        Colors.green,
                        'RM ${data['totalNetPay'].toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color, String value) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGeneratePayrollDialog() async {
    if (_selectedStaff == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _GeneratePayrollDialog(
        staffMember: _selectedStaff!,
        payrollService: _payrollService,
      ),
    );

    if (result != null) {
      _showSuccessSnackBar('Payroll generated successfully');
      await _loadPayrollRecords();
    }
  }

  Future<void> _approvePayroll(String recordId) async {
    try {
      await _payrollService.approvePayroll(payrollRecordId: recordId);
      _showSuccessSnackBar('Payroll approved');
      await _loadPayrollRecords();
    } catch (e) {
      _showErrorSnackBar('Failed to approve payroll: $e');
    }
  }

  Future<void> _markAsPaid(String recordId) async {
    try {
      await _payrollService.markPayrollAsPaid(
        payrollRecordId: recordId,
        paymentMethod: 'Bank Transfer',
        bankAccount: 'Account Number',
      );
      _showSuccessSnackBar('Payroll marked as paid');
      await _loadPayrollRecords();
    } catch (e) {
      _showErrorSnackBar('Failed to mark payroll as paid: $e');
    }
  }

  Future<void> _showPayStub(String recordId) async {
    try {
      final payStub = await _payrollService.generatePayStub(recordId);
      // Show pay stub dialog or navigate to pay stub screen
      _showPayStubDialog(payStub);
    } catch (e) {
      _showErrorSnackBar('Failed to generate pay stub: $e');
    }
  }

  void _showPayStubDialog(Map<String, dynamic> payStub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Stub'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pay stub content would go here
              Text('Pay stub for ${payStub['generatedAt']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _GeneratePayrollDialog extends StatefulWidget {
  final StaffMember staffMember;
  final PayrollService payrollService;

  const _GeneratePayrollDialog({
    required this.staffMember,
    required this.payrollService,
  });

  @override
  State<_GeneratePayrollDialog> createState() => _GeneratePayrollDialogState();
}

class _GeneratePayrollDialogState extends State<_GeneratePayrollDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  DateTime _payPeriodStart = DateTime.now().subtract(const Duration(days: 14));
  DateTime _payPeriodEnd = DateTime.now();
  double _basicSalary = 0.0;

  @override
  void initState() {
    super.initState();
    _basicSalary = widget.staffMember.monthlySalary ?? widget.staffMember.hourlyRate ?? 0.0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Payroll'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Staff: ${widget.staffMember.fullName}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Pay Period Start'),
                      subtitle: Text(_formatDate(_payPeriodStart)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Pay Period End'),
                      subtitle: Text(_formatDate(_payPeriodEnd)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _basicSalary.toString(),
                decoration: const InputDecoration(
                  labelText: 'Basic Salary (RM)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _basicSalary = double.tryParse(value) ?? 0.0,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter basic salary';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _generatePayroll,
          child: const Text('Generate Payroll'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _payPeriodStart : _payPeriodEnd,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _payPeriodStart = date;
        } else {
          _payPeriodEnd = date;
        }
      });
    }
  }

  Future<void> _generatePayroll() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.payrollService.generatePayroll(
        staffMemberId: widget.staffMember.id,
        payPeriodStart: _payPeriodStart,
        payPeriodEnd: _payPeriodEnd,
        basicSalary: _basicSalary,
        notes: _notesController.text,
      );
      Navigator.of(context).pop({
        'success': true,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate payroll: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
