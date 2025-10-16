import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helper_class/helper_message.dart';
import '../riverpod/data_provider.dart';
// class AuthService {
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   static Future<AuthResult> signUpWithFirebase({
//     required String email,
//     required String password,
//     required BuildContext context, // Add context parameter
//   }) async {
//     try {
//       // Validate input
//       if (email.isEmpty || password.isEmpty) {
//         AppSnackbar.error(
//           context: context,
//           message: 'Please fill all fields',
//         );
//         return AuthResult(error: 'Please fill all fields');
//       }
//
//       if (!isValidEmail(email)) {
//         AppSnackbar.error(
//           context: context,
//           message: 'Please enter a valid email',
//         );
//         return AuthResult(error: 'Please enter a valid email');
//       }
//
//       if (password.length < 6) {
//         AppSnackbar.error(
//           context: context,
//           message: 'Password must be at least 6 characters',
//         );
//         return AuthResult(error: 'Password must be at least 6 characters');
//       }
//
//       // Create user
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
//
//       // Send verification email
//       await userCredential.user?.sendEmailVerification();
//
//      var user=await storeUserData(email.trim(),password,userCredential);
//      debugPrint('User Saved 2 $user');
//       // Show success message
//       AppSnackbar.success(
//         context: context,
//         message: 'Account created! Please verify your email.',
//       );
//
//       return AuthResult(user: userCredential.user);
//
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = _getErrorMessage(e.code);
//
//       // Show error snackbar
//       AppSnackbar.error(
//         context: context,
//         message: errorMessage,
//       );
//
//       return AuthResult(error: errorMessage);
//     } catch (e) {
//       // Show generic error
//       AppSnackbar.error(
//         context: context,
//         message: 'An unexpected error occurred',
//       );
//
//       return AuthResult(error: 'An unexpected error occurred');
//     }
//   }
//
//
//   static Future<String?> storeUserData(String email, String password,UserCredential userInfo) async {
//     try {
//       // Create auth user
//
//       final user = userInfo.user!;
//
//       // Store in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .set({
//         'uid': user.uid,
//         'email': email.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       return user.uid; // Success
//     } on FirebaseAuthException catch (e) {
//       return e.code; // Error code
//     }
//   }
//
//   // Login method with snackbar
//   static Future<AuthResult> loginWithFirebase({
//     required String email,
//     required BuildContext context,
//   }) async {
//     try {
//       // Validate input
//       if (email.isEmpty) {
//         AppSnackbar.error(
//           context: context,
//           message: 'Please enter your email',
//         );
//         return AuthResult(error: 'Please enter your email');
//       }
//
//       if (!isValidEmail(email)) {
//         AppSnackbar.error(
//           context: context,
//           message: 'Please enter a valid email',
//         );
//         return AuthResult(error: 'Please enter a valid email');
//       }
//
//       // For email-only login, we'll use signInWithEmailLink or create a custom flow
//       // This is a simplified version - you might need to adjust based on your auth flow
//       AppSnackbar.info(
//         context: context,
//         message: 'Login functionality to be implemented',
//       );
//
//       return AuthResult(error: 'Login method not implemented');
//
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = _getLoginErrorMessage(e.code);
//
//       AppSnackbar.error(
//         context: context,
//         message: errorMessage,
//       );
//
//       return AuthResult(error: errorMessage);
//     } catch (e) {
//       AppSnackbar.error(
//         context: context,
//         message: 'An unexpected error occurred',
//       );
//
//       return AuthResult(error: 'An unexpected error occurred');
//     }
//   }
//
//   static String _getErrorMessage(String errorCode) {
//     switch (errorCode) {
//       case 'email-already-in-use':
//         return 'This email is already registered';
//       case 'invalid-email':
//         return 'Invalid email address';
//       case 'operation-not-allowed':
//         return 'Email/password accounts are not enabled';
//       case 'weak-password':
//         return 'Password is too weak';
//       default:
//         return 'Registration failed. Please try again';
//     }
//   }
//
//   static String _getLoginErrorMessage(String errorCode) {
//     switch (errorCode) {
//       case 'user-not-found':
//         return 'No account found with this email';
//       case 'wrong-password':
//         return 'Invalid password';
//       case 'invalid-email':
//         return 'Invalid email address';
//       case 'user-disabled':
//         return 'This account has been disabled';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later';
//       default:
//         return 'Login failed. Please try again';
//     }
//   }
//
//
//
//   static Future<User?> verifyUserWithEmailPassword(String email, String password,BuildContext context,WidgetRef ref) async {
//     TextHelper.clearText(ref);
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//
//
//       debugPrint('User verified successfully: ${userCredential.user?.email}');
//       AppSnackbar.success(
//         context: context,
//         message: 'User verified successfully!!',
//       );
//       return userCredential.user;
//
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         print('No user found with that email');
//       } else if (e.code == 'wrong-password') {
//         print('Wrong password provided');
//       } else if (e.code == 'invalid-email') {
//         print('Invalid email address');
//       } else {
//         print('Authentication error: ${e.code}');
//       }
//
//       TextHelper.changeText(ref, 'Error : $e');
//       return null;
//     } catch (e) {
//
//       print('Error verifying user: $e');
//       TextHelper.changeText(ref, 'Error : $e');
//       return null;
//     }
//   }
//
//   static bool isValidEmail(String email) {
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     return emailRegex.hasMatch(email);
//   }
// }
//
// class AuthResult {
//   final User? user;
//   final String? error;
//
//   AuthResult({this.user, this.error});
//
//   bool get isSuccess => user != null;
//   bool get hasError => error != null;
// }
//
// // Snackbar Service (include this in your file)
// class AppSnackbar {
//   static void show({
//     required BuildContext context,
//     required String message,
//     Color backgroundColor = Colors.blue,
//     Color textColor = Colors.white,
//     Duration duration = const Duration(seconds: 3),
//     SnackBarBehavior behavior = SnackBarBehavior.floating,
//     String? actionLabel,
//     VoidCallback? onActionPressed,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(color: textColor),
//         ),
//         backgroundColor: backgroundColor,
//         duration: duration,
//         behavior: behavior,
//         action: actionLabel != null
//             ? SnackBarAction(
//           label: actionLabel,
//           textColor: textColor,
//           onPressed: onActionPressed ?? () {},
//         )
//             : null,
//       ),
//     );
//   }
//
//   static void success({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onActionPressed,
//   }) {
//     show(
//       context: context,
//       message: message,
//       backgroundColor: Colors.green,
//       actionLabel: actionLabel,
//       onActionPressed: onActionPressed,
//     );
//   }
//
//   static void error({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onActionPressed,
//   }) {
//     show(
//       context: context,
//       message: message,
//       backgroundColor: Colors.red,
//       actionLabel: actionLabel,
//       onActionPressed: onActionPressed,
//     );
//   }
//
//   static void warning({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onActionPressed,
//   }) {
//     show(
//       context: context,
//       message: message,
//       backgroundColor: Colors.orange,
//       actionLabel: actionLabel,
//       onActionPressed: onActionPressed,
//     );
//   }
//
//   static void info({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onActionPressed,
//   }) {
//     show(
//       context: context,
//       message: message,
//       backgroundColor: Colors.blue,
//       actionLabel: actionLabel,
//       onActionPressed: onActionPressed,
//     );
//   }
// }