import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/riverpod/auth_provider.dart';
import 'package:yunusco_accessories/screens/create_costing_screen.dart';
import 'package:yunusco_accessories/screens/dashboard_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isLoginLoading = false;
  bool _isSignupLoading = false;
  bool _obscurePassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    getSavedValues();
    _tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter username and password');
      return;
    }

    setState(() => _isLoginLoading = true);

    try {
      // Call your Riverpod provider API
       var response= await ref.read(authProvider.notifier).loginUser(email, password);
       debugPrint('CURRENT RESPONSE ${response}');
       if(response){
         DashboardHelper.saveString('user', _loginEmailController.text.trim());
         DashboardHelper.saveString('pass', _loginPasswordController.text.trim());
         Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => const SimpleDashboardScreen()),
         );

       }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _signup() async {
    final email = _signupEmailController.text.trim();
    final pass = _signupPasswordController.text.trim();
    final confirm = _signupConfirmPasswordController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (pass != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isSignupLoading = true);

    try {
      // Example call to signup API
      await ref.read(authProvider.notifier).signupUser(email, pass);
    } catch (e) {
      _showError('Signup failed: $e');
    } finally {
      setState(() => _isSignupLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.business, color: Color(0xFF2C5530), size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Yunusco BD Ltd',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5530),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Premium Garments Accessories',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF2C5530),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    indicatorSize: TabBarIndicatorSize.tab, // 👈 important line
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    tabs: const [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Login'),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                if (authState.error != null)
                  Text(authState.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),

                 SizedBox(
                   height: 400,
                   child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _textField(
          controller: _loginEmailController,
          hint: 'Enter username',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _loginPasswordController,
          hint: 'Enter password',
          icon: Icons.lock,
          obscureText: _obscurePassword,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 24),
        _actionButton(
          text: 'Login',
          loading: _isLoginLoading,
          onPressed: _login,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _textField(
          controller: _signupEmailController,
          hint: 'Enter email',
          icon: Icons.email,
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _signupPasswordController,
          hint: 'Create password',
          icon: Icons.lock,
          obscureText: _obscureSignupPassword,
          onSuffixTap: () =>
              setState(() => _obscureSignupPassword = !_obscureSignupPassword),
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _signupConfirmPasswordController,
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          onSuffixTap: () =>
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        const SizedBox(height: 24),
        _actionButton(
          text: 'Sign Up',
          loading: _isSignupLoading,
          onPressed: _signup,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: onSuffixTap != null
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: onSuffixTap,
          )
              : null,
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C5530),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void getSavedValues() async{
    var user=await DashboardHelper.getString('user');
    var pass=await DashboardHelper.getString('pass');
    debugPrint('Previous user ${user}');
    debugPrint('Previous pass ${pass}');
    if(user!=null&&pass!=null){
      setState(() {
        _loginEmailController.text=user;
        _loginPasswordController.text=pass;
      });
    }
  }
}
