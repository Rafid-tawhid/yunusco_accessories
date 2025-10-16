import 'package:flutter/material.dart';
import 'package:yunusco_accessories/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yunusco_accessories/riverpod/auth_provider.dart';
import 'package:yunusco_accessories/riverpod/data_provider.dart';
import 'package:yunusco_accessories/widgets/password_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isLoginLoading = false;
  bool _isSignupLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_loginEmailController.text.isEmpty) {
      _showError('Please enter your username');
      return;
    }

    // if (!_isValidEmail(_loginEmailController.text)) {
    //   _showError('Please enter a valid email');
    //   return;
    // }

    //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    //var data=await _firestore.collection('users').where('email',isEqualTo: _loginEmailController.text.trim()).limit(1).get();


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordBottomSheet(
        onPasswordVerified: (password) {
        },
        title: 'Admin Access',
        email:_loginEmailController.text.trim(),
        description: 'Enter admin password to proceed',
      ),
    );
    // if(data.docs.isNotEmpty){
    //   showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     backgroundColor: Colors.transparent,
    //     builder: (context) => PasswordBottomSheet(
    //       onPasswordVerified: (password) {
    //       },
    //       title: 'Admin Access',
    //       email:_loginEmailController.text.trim(),
    //       description: 'Enter admin password to proceed',
    //     ),
    //   );
    // }

  }

  void _signup() async {
    if (_signupEmailController.text.isEmpty ||
        _signupPasswordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (!_isValidEmail(_signupEmailController.text)) {
      _showError('Please enter a valid email');
      return;
    }

    if (_signupPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (_signupPasswordController.text != _signupConfirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isSignupLoading = true;
    });

    //var result=await AuthService.signUpWithFirebase(email:_signupEmailController.text.trim(),password:  _signupPasswordController.text.trim(), context: context);

    // debugPrint('result ${result.toString()}');

    setState(() {
      _isSignupLoading = false;
    });


    // Navigate to home screen
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with Logo
                SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2C5530),
                        Color(0xFF4A7C59),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2C5530).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.brush_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Yunusco BD Ltd',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5530),
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Premium Garments Accessories',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                SizedBox(height: 40),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF2C5530),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    tabs: [
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Login'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
                Consumer(
                  builder: (context,ref,_) {
                    final authState = ref.watch(authProvider);
                    return Text(authState.error??'',style: TextStyle(color: Colors.red),);
                  }
                ),

                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Login Tab
                      _buildLoginForm(),

                      // Signup Tab
                      _buildSignupForm(),
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

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5530),
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Sign in to continue to your account',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 40),

          // Email Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _loginEmailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded, color: Colors.grey[600]),
                hintText: 'Enter your username',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          SizedBox(height: 30),


          // Login Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoginLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C5530),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoginLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Forgot Password
          TextButton(
            onPressed: () {
              _showError('Password reset feature coming soon');
            },
            child: Text(
              'Forgot your email?',
              style: TextStyle(
                color: Color(0xFF4A7C59),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5530),
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Sign up to get started with Yunusco',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 40),

          // Email Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _signupEmailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded, color: Colors.grey[600]),
                hintText: 'Enter your email',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          SizedBox(height: 20),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _signupPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey[600]),
                hintText: 'Create password',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Confirm Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _signupConfirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[600]),
                hintText: 'Confirm password',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 30),

          // Signup Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isSignupLoading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C5530),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSignupLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Terms and Conditions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'By creating an account, you agree to our Terms of Service and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

