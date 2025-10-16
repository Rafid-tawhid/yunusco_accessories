// lib/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helper_class/api_service_class.dart';
import 'package:dio/dio.dart';

import '../helper_class/response_state.dart';

// Create global instances
final apiServiceProvider = Provider((ref) => ApiService());

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, ResponseState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});


// Auth notifier
class AuthNotifier extends StateNotifier<ResponseState> {
  final ApiService apiService;

  AuthNotifier(this.apiService) : super(const ResponseState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.post('api/Accounts/GetUserLogin', {
        'username': email,
        'password': password,
      });

      if (response?.statusCode == 200) {
        // Set token for future requests
        if (response!.data['token'] != null) {
          apiService.setToken(response.data['token']);
        }

        state = state.copyWith(
          isLoading: false,
          response: response.data,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response?.data?['message']??response?.data?['msg'] ?? 'Login failed',
        );
      }
    } on DioError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}