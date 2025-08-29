import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/pet_inspection_widget.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/checkin_payment_widget.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_service.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';

class CheckInDialog extends ConsumerStatefulWidget {
  final Booking? existingBooking;
  final String? customerId;
  final String? customerName;
  final String? petId;
  final String? petName;
  
  const CheckInDialog({
    super.key,
    this.existingBooking,
    this.customerId,
    this.customerName,
    this.petId,
    this.petName,
  });

  @override
  ConsumerState<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<CheckInDialog> {
  int _currentStep = 0;
  PetInspection? _completedInspection;
  PaymentTransaction? _completedPayment;
  CheckInResult? _checkInResult;
  bool _isProcessing = false;

  final List<String> _stepTitles = [
    'Pet Inspection',
    'Room Assignment', 
    'Payment Processing',
    'Final Confirmation',
    'Completion'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: _buildStepContent(),
            ),
            
            // Navigation Buttons
            const SizedBox(height: 16),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Check-In Process';
    String subtitle = '';
    
    if (widget.existingBooking != null) {
      title = 'Check-In: ${widget.existingBooking!.bookingNumber}';
      subtitle = '${widget.existingBooking!.customerName} - ${widget.existingBooking!.petName}';
    } else if (widget.customerName != null && widget.petName != null) {
      title = 'Walk-In Check-In';
      subtitle = '${widget.customerName!} - ${widget.petName!}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.pets, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_stepTitles.length, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isActive
                          ? Colors.blue
                          : Colors.grey[300],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < _stepTitles.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPetInspectionStep();
      case 1:
        return _buildRoomAssignmentStep();
      case 2:
        return _buildPaymentProcessingStep();
      case 3:
        return _buildFinalConfirmationStep();
      case 4:
        return _buildCompletionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPetInspectionStep() {
    final petId = widget.petId ?? widget.existingBooking?.petId;
    
    if (petId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Pet information not available'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stepTitles[0],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: PetInspectionWidget(
              petId: petId,
              onInspectionCompleted: (inspection) {
                setState(() {
                  _completedInspection = inspection;
                });
                _nextStep();
              },
              onSkip: () {
                // Create a basic inspection record
                _completedInspection = null; // Skip inspection
                _nextStep();
              },
              allowSkip: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomAssignmentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stepTitles[1],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hotel, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Room Assignment',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Room assignment functionality will be implemented in the next phase.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // For now, automatically assign a room
                    _nextStep();
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Auto-Assign Room'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentProcessingStep() {
    final customerId = widget.customerId ?? widget.existingBooking?.customerId ?? '';
    final customerName = widget.customerName ?? widget.existingBooking?.customerName ?? '';
    final petId = widget.petId ?? widget.existingBooking?.petId ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stepTitles[2],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: CheckInPaymentWidget(
              booking: widget.existingBooking,
              customerId: customerId,
              customerName: customerName,
              checkInId: 'CHK-${DateTime.now().millisecondsSinceEpoch}',
              selectedServices: const [], // TODO: Get from earlier steps
              onPaymentCompleted: (transaction) {
                setState(() {
                  _completedPayment = transaction;
                });
                _nextStep();
              },
              onSkip: () {
                // Allow skipping payment in some cases
                _nextStep();
              },
              allowSkip: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stepTitles[3],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inspection Summary
                if (_completedInspection != null) ...[
                  const Text(
                    'Pet Inspection Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall Condition: ${_completedInspection!.overallCondition}'),
                          Text('Inspector: ${_completedInspection!.inspectedBy}'),
                          Text('Status: ${_completedInspection!.approved == true ? 'APPROVED' : 'NEEDS ATTENTION'}'),
                          if (_completedInspection!.inspectionNotes != null)
                            Text('Notes: ${_completedInspection!.inspectionNotes}'),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Pet inspection was skipped'),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Payment Summary
                if (_completedPayment != null) ...[
                  const Text(
                    'Payment Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text('Payment Processed', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Amount: RM ${_completedPayment!.amount.toStringAsFixed(2)}'),
                          Text('Method: ${_completedPayment!.paymentMethod.name}'),
                          Text('Transaction ID: ${_completedPayment!.transactionId}'),
                          if (_completedPayment!.receiptId != null)
                            Text('Receipt: ${_completedPayment!.receiptId}'),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('No payment processed during check-in'),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Booking Information
                const Text(
                  'Check-In Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.existingBooking != null) ...[
                          Text('Booking: ${widget.existingBooking!.bookingNumber}'),
                          Text('Customer: ${widget.existingBooking!.customerName}'),
                          Text('Pet: ${widget.existingBooking!.petName}'),
                          Text('Room: ${widget.existingBooking!.roomNumber}'),
                        ] else ...[
                          Text('Customer: ${widget.customerName ?? 'Unknown'}'),
                          Text('Pet: ${widget.petName ?? 'Unknown'}'),
                          const Text('Room: Auto-assigned'),
                        ],
                        Text('Check-in Time: ${DateTime.now().toString().substring(0, 16)}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stepTitles[4],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check-In Complete!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Pet has been successfully checked in.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    if (_completedPayment != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Payment of RM ${_completedPayment!.amount.toStringAsFixed(2)} has been processed.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_completedPayment != null) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Print receipt
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receipt printing not implemented yet')),
                          );
                        },
                        icon: const Icon(Icons.receipt),
                        label: const Text('Print Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    if (_isProcessing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        if (_currentStep > 0 && _currentStep < 4)
          TextButton.icon(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          )
        else
          const SizedBox.shrink(),
        
        // Next/Complete Button
        if (_currentStep < 4)
          ElevatedButton.icon(
            onPressed: _currentStep == 3 ? _processCheckIn : _nextStep,
            icon: Icon(_currentStep == 3 ? Icons.check : Icons.arrow_forward),
            label: Text(_currentStep == 3 ? 'Complete Check-In' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _processCheckIn() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // For now, just simulate processing
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isProcessing = false;
      });
      
      _nextStep();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: $e')),
        );
      }
    }
  }
}