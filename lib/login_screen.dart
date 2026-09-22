import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/riverpod/auth_provider.dart';
import 'package:yunusco_accessories/screens/dashboard_screen.dart';
import 'package:yunusco_accessories/theme/app_theme.dart';
import 'package:yunusco_accessories/widgets/fade_slide_in.dart';

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
        backgroundColor: AppColors.danger,
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
      var response = await ref.read(authProvider.notifier).loginUser(email, password);
      debugPrint('CURRENT RESPONSE $response');
      if (response) {
        DashboardHelper.saveString('user', _loginEmailController.text.trim());
        DashboardHelper.saveString('pass', _loginPasswordController.text.trim());
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          AppTheme.pageRoute(const SimpleDashboardScreen()),
        );
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
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
      await ref.read(authProvider.notifier).signupUser(email, pass);
    } catch (e) {
      _showError('Signup failed: $e');
    } finally {
      if (mounted) setState(() => _isSignupLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Decorative gradient header behind the card
          Container(
            height: 260,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.business, color: AppColors.primary, size: 38),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Yunusco T&A BD',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Premium Garments Accessories',
                          style: TextStyle(fontSize: 13.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: AppColors.primaryGradient,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey[700],
                              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              tabs: const [
                                Tab(text: 'Login'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: authState.error != null
                                ? Padding(
                                    key: ValueKey(authState.error),
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(color: AppColors.danger, fontSize: 13),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOut,
                            child: SizedBox(
                              height: 360,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginForm(),
                                  _buildSignupForm(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _loginPasswordController,
          hint: 'Enter password',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
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
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _signupPasswordController,
          hint: 'Create password',
          icon: Icons.lock_outline,
          obscureText: _obscureSignupPassword,
          onSuffixTap: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _signupConfirmPasswordController,
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: onSuffixTap != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: onSuffixTap,
              )
            : null,
        hintText: hint,
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
      height: 54,
      child: TapScale(
        onTap: loading ? null : onPressed,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: loading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    text,
                    key: ValueKey(text),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void getSavedValues() async {
    var user = await DashboardHelper.getString('user');
    var pass = await DashboardHelper.getString('pass');
    debugPrint('Previous user $user');
    debugPrint('Previous pass $pass');
    if (user != null && pass != null) {
      setState(() {
        _loginEmailController.text = user;
        _loginPasswordController.text = pass;
      });
    }
  }
}
