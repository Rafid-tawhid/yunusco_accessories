// lib/providers/data_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helper_class/api_service_class.dart';
import '../helper_class/response_state.dart';
import 'auth_provider.dart';

// Provider for your specific data
final userDataProvider = StateNotifierProvider<DataNotifier, ResponseState>((ref) {
  return DataNotifier(ref.read(apiServiceProvider));
});

// You can reuse the same ResponseState class
class DataNotifier extends StateNotifier<ResponseState> {
  final ApiService apiService;

  DataNotifier(this.apiService) : super(const ResponseState());

  // Method to fetch your data
  Future<void> getUserData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.get('api/Users/GetAllUsers');

      if (response?.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          response: response!.data,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load data',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong',
      );
    }
  }

  // Method to post data
  Future<void> createUser(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.post('api/Users/CreateUser', userData);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          response: response!.data,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create user',
        );
      }
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