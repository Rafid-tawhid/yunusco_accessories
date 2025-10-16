import 'package:flutter/material.dart';

import '../dashboard_screen.dart';
import '../firebase/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/role_provider.dart';

class PasswordBottomSheet extends ConsumerStatefulWidget {
  final Function(String) onPasswordVerified;
  final String title;
  final String description;
  final String email;

  const PasswordBottomSheet({
    Key? key,
    required this.onPasswordVerified,
    this.title = 'Enter Password',
    this.email='',
    this.description = 'Please enter your password to continue',
  }) : super(key: key);

  @override
  _PasswordBottomSheetState createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends ConsumerState<PasswordBottomSheet> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String _errorMessage = '';

  void _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });



   var user=await AuthService.verifyUserWithEmailPassword(widget.email,_passwordController.text.trim(),context,ref);

    setState(() {
      _isLoading = false;
    });
    if(user!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen(
        userName: 'Rafid',
        userRole: 'Admin',
      )));
    }

    // Call the callback with the entered password
    widget.onPasswordVerified(_passwordController.text);

    // Clear the password field
    _passwordController.clear();
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final text = ref.watch(textProvider);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 32,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[200]),

              // Password input section
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _errorMessage.isNotEmpty
                                ? Colors.red
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          onChanged: (_) => _clearError(),
                          onSubmitted: (_) => _verifyPassword(),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Text(text,style: TextStyle(color: Colors.red),),
                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),

                          // Verify button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Forgot password
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Forgot password feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
