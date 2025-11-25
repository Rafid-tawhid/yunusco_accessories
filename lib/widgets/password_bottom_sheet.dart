// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yunusco_accessories/create_costing_screen.dart';
// import '../riverpod/auth_provider.dart';
//
// class PasswordBottomSheet extends ConsumerWidget {
//   final Function(String) onPasswordVerified;
//   final String title;
//   final String description;
//   final String email;
//
//   const PasswordBottomSheet({
//     Key? key,
//     required this.onPasswordVerified,
//     this.title = 'Enter Password',
//     this.email = '',
//     this.description = 'Please enter your password to continue',
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final passwordController = TextEditingController();
//     final obscureText = ValueNotifier<bool>(true);
//
//     final authState = ref.watch(authProvider);
//
//     void verifyPassword() {
//       if (passwordController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter your password')),
//         );
//         return;
//       }
//
//       ref.read(authProvider.notifier).login(email,passwordController.text.trim());
//     }
//
//     // Handle successful login
//     if (authState.response!=null) {
//       debugPrint(authState.error);
//       debugPrint(authState.response.toString());
//       WidgetsBinding.instance.addPostFrameCallback((e){
//         if(authState.response!['output']=='success'){
//           Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=>DashboardScreen(userName: 'Rafid', userRole: 'Admin')));
//         }
//       });
//
//     }
//
//     return DraggableScrollableSheet(
//       initialChildSize: 0.45,
//       minChildSize: 0.3,
//       maxChildSize: 0.7,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             children: [
//               // Drag handle
//               Container(
//                 margin: const EdgeInsets.only(top: 12, bottom: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[400],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 child: Column(
//                   children: [
//                     // Icon
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.lock_outline,
//                         size: 32,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Title
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                     // Description
//                     Text(
//                       description,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Divider(height: 1),
//
//               // Password input section
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       // Password field
//                       ValueListenableBuilder<bool>(
//                         valueListenable: obscureText,
//                         builder: (context, isObscure, child) {
//                           return TextField(
//                             controller: passwordController,
//                             obscureText: isObscure,
//                             onSubmitted: (_) => verifyPassword(),
//                             decoration: InputDecoration(
//                               hintText: 'Enter your password',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               prefixIcon: const Icon(Icons.lock_outline),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   isObscure
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                 ),
//                                 onPressed: () {
//                                   obscureText.value = !obscureText.value;
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       // Error message
//                       if (authState.error != null) ...[
//                         const SizedBox(height: 8),
//                         Text(
//                           authState.error!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ],
//
//                       const SizedBox(height: 24),
//
//                       // Action buttons
//                       Row(
//                         children: [
//                           // Cancel button
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: authState.isLoading ? null : () => Navigator.pop(context),
//                               style: OutlinedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: const Text('Cancel'),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//
//                           // Verify button
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: authState.isLoading ? null : verifyPassword,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: authState.isLoading
//                                   ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                                   : const Text('Verify'),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // Forgot password
//                       TextButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Forgot password feature coming soon!')),
//                           );
//                         },
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(color: Colors.green),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
