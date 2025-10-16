import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/data_provider.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

//
class _UserScreenState extends ConsumerState<UserScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userDataProvider.notifier).getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.error != null
          ? Center(child: Text('Error: ${userState.error}'))
          : userState.response != null
          ? _buildUserList(userState.response!)
          : const Center(child: Text('No data')),
    );
  }

  Widget _buildUserList(Map<String, dynamic> response) {
    // Your list building logic
    return ListView(
      children: [
        // Your data here
      ],
    );
  }
}