import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import 'repository_providers.dart';

class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(AuthState());

  final AuthRepository _repository;

  Future<bool> loginUser(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _repository.login(email, password);
      if (!result.isSuccess) {
        state = state.copyWith(error: 'Login failed: ${result.message ?? ''}');
      }
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false; // Error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signupUser(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // Example API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
