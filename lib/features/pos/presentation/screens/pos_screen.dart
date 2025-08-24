import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/product_grid.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/cart_section.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/payment_section.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/quick_actions.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/held_carts_drawer.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/customer_search_section.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  Timer? _timer;
  String _currentTime = '';
  String _currentUserName = '';
  String _currentUserRole = '';

  @override
  void initState() {
    super.initState();
    // Create a new cart when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentCartProvider.notifier).createNewCart();
    });
    
    // Load current user information
    _loadCurrentUser();
    
    // Initialize and start the timer for real-time clock
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = await SecureStorageService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _currentUserName = userData['fullName'] ?? 'Unknown User';
          _currentUserRole = userData['role'] ?? 'Unknown Role';
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Enhanced Header with Material Design 3
          _buildEnhancedHeader(context, theme),
          
          // Quick Actions Bar with improved styling
          _buildQuickActionsBar(),
          
          // Customer Search Section
          const CustomerSearchSection(),
          
          // Main content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[50]!,
                    Colors.blue[50]!,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Left Side - Product Grid with enhanced styling
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: ProductGrid(),
                      ),
                    ),
                  ),
                  
                  // Right Side - Cart and Payment side by side
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(-4, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: Row(
                          children: [
                            // Cart Section
                            Expanded(
                              flex: 1,
                              child: CartSection(),
                            ),
                            
                            // Payment Section
                            Expanded(
                              flex: 1,
                              child: PaymentSection(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      endDrawer: const HeldCartsDrawer(),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo[700]!,
            Colors.indigo[500]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Left Section - Logo and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Icon(
                      Icons.point_of_sale,
                      color: Colors.indigo[700],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Register',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cat Hotel POS System',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Center Section - Staff Information
              Expanded(
                child: Center(
                  child: _currentUserName.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Staff Member',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    _currentUserName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                                ),
                                child: Text(
                                  _currentUserRole.toUpperCase(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              
              // Right Section - Action Buttons
              Row(
                children: [
                  // Current Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.indigo[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentTime,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.indigo[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Back to Dashboard Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.dashboard,
                        color: Colors.indigo[700],
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                      tooltip: 'Back to Dashboard',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const QuickActions(),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    // Format: DD-MMM-YYYY HH:MM:SS (date and time)
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final date = '${now.day.toString().padLeft(2, '0')}-${monthNames[now.month - 1]}-${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
