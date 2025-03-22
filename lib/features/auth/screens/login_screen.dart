import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/routes/app_routes.dart';
import '../provider/auth_provider.dart';
import '../../../widgets/common_header.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _loginType = 'user'; // 'user', 'admin', or 'teacher'
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        isAdminLogin: _loginType == 'admin',
      );

      if (mounted) {
        if (success) {
          final user = authProvider.currentUser;
          if (user?.role == UserRole.admin) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          } else if (user?.role == UserRole.teacher) {
            Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: CommonHeader(title: 'Login'),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          // Login Type Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('User'),
                                  selected: _loginType == 'user',
                                  onSelected: (selected) {
                                    setState(() {
                                      _loginType = 'user';
                                      _emailController.clear();
                                      _passwordController.clear();
                                    });
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Teacher'),
                                  selected: _loginType == 'teacher',
                                  onSelected: (selected) {
                                    setState(() {
                                      _loginType = 'teacher';
                                      _emailController.text = 'teacher@educationguide.com';
                                      _passwordController.text = 'teacher123';
                                    });
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Admin'),
                                  selected: _loginType == 'admin',
                                  onSelected: (selected) {
                                    setState(() {
                                      _loginType = 'admin';
                                      _emailController.text = 'admin@educationguide.com';
                                      _passwordController.text = 'admin123';
                                    });
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(() => 
                                _obscurePassword = !_obscurePassword
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildRememberForgot(),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'Login',
                              onPressed: authProvider.isLoading 
                                  ? () {} // Empty function when loading
                                  : _handleLogin,
                              isLoading: authProvider.isLoading,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_loginType != 'admin') _buildSignUpOption(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}