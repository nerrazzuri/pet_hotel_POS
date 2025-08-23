import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/auth/presentation/providers/auth_providers.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/biometric_auth_service.dart';
import 'package:cat_hotel_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadStoredCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    final status = await BiometricAuthService.getBiometricStatus();
    setState(() {
      _isBiometricAvailable = status.canUseBiometrics;
      _isBiometricEnabled = status.isEnabled;
    });
  }

  /// Load stored credentials if remember me is enabled
  Future<void> _loadStoredCredentials() async {
    // This will be handled by the auth provider
  }

  /// Handle login form submission
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authStateProvider.notifier);
    final result = await authNotifier.login(
      _usernameController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (result.isSuccess && mounted) {
      print('LoginScreen: Login successful, navigating to dashboard');
      print('LoginScreen: Username: ${_usernameController.text.trim()}');
      
      // Verify user data was stored
      final userData = await SecureStorageService.getUserData();
      print('LoginScreen: User data in storage after login: $userData');
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  /// Handle biometric login
  Future<void> _loginWithBiometrics() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final result = await authNotifier.loginWithBiometrics();

    if (result.isSuccess && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  /// Show biometric setup dialog
  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Authentication'),
        content: const Text(
          'Would you like to enable biometric authentication for faster login? '
          'You can change this setting later in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await BiometricAuthService.setBiometricEnabled(true);
              setState(() {
                _isBiometricEnabled = true;
              });
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  /// Show demo login dialog
  void _showDemoLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Login'),
        content: const Text(
          'Choose a role to login with demo credentials:\n\n'
          '• Admin: admin/admin123\n'
          '• Owner: owner/owner123\n'
          '• Manager: manager/manager123\n'
          '• Staff: staff/staff123',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usernameController.text = 'admin';
              _passwordController.text = 'admin123';
              _login();
            },
            child: const Text('Admin'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usernameController.text = 'owner';
              _passwordController.text = 'owner123';
              _login();
            },
            child: const Text('Owner'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usernameController.text = 'manager';
              _passwordController.text = 'manager123';
              _login();
            },
            child: const Text('Manager'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usernameController.text = 'staff';
              _passwordController.text = 'staff123';
              _login();
            },
            child: const Text('Staff'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final biometricStatus = ref.watch(biometricStatusProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade50,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Cat Hotel POS',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Login Form
                      Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Remember Me & Biometric
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text('Remember me'),
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              ),
                              if (_isBiometricAvailable)
                                IconButton(
                                  onPressed: _isBiometricEnabled 
                                      ? _loginWithBiometrics
                                      : _showBiometricSetupDialog,
                                  icon: Icon(
                                    _isBiometricEnabled 
                                        ? Icons.fingerprint
                                        : Icons.fingerprint_outlined,
                                    color: _isBiometricEnabled 
                                        ? Colors.teal
                                        : Colors.grey,
                                  ),
                                  tooltip: _isBiometricEnabled 
                                      ? 'Login with biometrics'
                                      : 'Enable biometric authentication',
                                ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Error Message
                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Demo Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: _showDemoLoginDialog,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Demo Login'),
                        ),
                      ),
                      
                      // Biometric Status Info
                      if (_isBiometricAvailable) ...[
                        const SizedBox(height: 16),
                        biometricStatus.when(
                          data: (status) => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    status.statusDescription,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Footer
                      Text(
                        '© 2024 Cat Hotel POS. All rights reserved.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
