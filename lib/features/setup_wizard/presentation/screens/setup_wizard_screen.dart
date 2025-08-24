import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/auth_service.dart';
import 'package:cat_hotel_pos/features/auth/presentation/providers/auth_providers.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/widgets/feature_configuration_tab.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/widgets/permission_setup_tab.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/widgets/business_configuration_tab.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/widgets/setup_completion_tab.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/providers/setup_wizard_providers.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentStep = 0;
  bool _isPasswordVerified = false;
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<SetupStep> _setupSteps = [
    SetupStep(
      title: 'Business Configuration',
      description: 'Configure business details and basic settings',
      icon: Icons.business,
      color: Colors.blue,
    ),
    SetupStep(
      title: 'Feature Configuration',
      description: 'Enable/disable system features and modules',
      icon: Icons.featured_play_list,
      color: Colors.green,
    ),
    SetupStep(
      title: 'Permission Setup',
      description: 'Configure role-based access and permissions',
      icon: Icons.security,
      color: Colors.orange,
    ),
    SetupStep(
      title: 'Setup Completion',
      description: 'Review and finalize configuration',
      icon: Icons.check_circle,
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _setupSteps.length, vsync: this);
    _pageController = PageController();
    
    // Check if user is admin or owner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkUserRole() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final isAdminOrOwner = currentUser.role == UserRole.administrator || 
                            currentUser.role == UserRole.owner;
      if (!isAdminOrOwner) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Only administrators and business owners can access this feature.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

                    final userService = ref.read(userServiceProvider);
                final auditService = ref.read(auditServiceProvider);
                final authService = AuthService(userService, auditService);
                final isValid = await authService.verifyPassword(
                  currentUser.username,
                  _passwordController.text,
                );

    if (isValid) {
      setState(() {
        _isPasswordVerified = true;
      });
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password verified. Welcome to the Setup Wizard!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _setupSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _tabController.animateTo(step);
  }

  Future<void> _completeSetup() async {
    try {
      final setupProvider = ref.read(setupWizardProvider.notifier);
      await setupProvider.saveConfiguration();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setup completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing setup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdminOrOwner = currentUser.role == UserRole.administrator || 
                          currentUser.role == UserRole.owner;

    if (!isAdminOrOwner) {
      return const Scaffold(
        body: Center(
          child: Text('Access denied. Only administrators and business owners can access this feature.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Time Setup Wizard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isPasswordVerified)
            IconButton(
              icon: const Icon(Icons.lock_open),
              onPressed: () {
                setState(() {
                  _isPasswordVerified = false;
                });
              },
              tooltip: 'Lock Setup Wizard',
            ),
        ],
      ),
      body: _isPasswordVerified ? _buildWizardContent() : _buildPasswordVerification(),
    );
  }

  Widget _buildPasswordVerification() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Setup Wizard Access',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This wizard allows you to configure system features and permissions. Please verify your identity to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Your Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _verifyPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Verify & Continue',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWizardContent() {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Step tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: _setupSteps.map((step) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _currentStep >= _setupSteps.indexOf(step)
                                ? step.color
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            color: _currentStep >= _setupSteps.indexOf(step)
                                ? Colors.white
                                : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(step.title),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Progress bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _setupSteps.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${_currentStep + 1} of ${_setupSteps.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Content area
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
              _tabController.animateTo(index);
            },
            children: [
              BusinessConfigurationTab(
                onNext: _nextStep,
                onStepComplete: (config) {
                  ref.read(setupWizardProvider.notifier).updateBusinessConfig(config);
                },
              ),
              FeatureConfigurationTab(
                onNext: _nextStep,
                onPrevious: _previousStep,
                onStepComplete: (config) {
                  ref.read(setupWizardProvider.notifier).updateFeatureConfig(config);
                },
              ),
              PermissionSetupTab(
                onNext: _nextStep,
                onPrevious: _previousStep,
                onStepComplete: (config) {
                  ref.read(setupWizardProvider.notifier).updatePermissionConfig(config);
                },
              ),
              SetupCompletionTab(
                onPrevious: _previousStep,
                onComplete: _completeSetup,
                onGoToStep: _goToStep,
              ),
            ],
          ),
        ),
        
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Previous'),
                )
              else
                const SizedBox.shrink(),
              
              if (_currentStep < _setupSteps.length - 1)
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next'),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SetupStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
