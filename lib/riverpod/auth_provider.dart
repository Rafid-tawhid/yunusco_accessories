import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/api_service_class.dart';
import 'package:yunusco_accessories/helper_class/user_data.dart';
import 'package:yunusco_accessories/models/user_model.dart';



class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> loginUser(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      ApiService apiService = ApiService();
      var data = await apiService.post('Login/Login', {
        'LoginName': email,
        'Password': password
      });
      debugPrint('This is data ${data!.data['output'].toString()=="success"}');

      if (data.data['output'].toString()=="success") {
        UserData.user = UserModel.fromJson(data.data['rValue']);
        debugPrint('Is this calling ??');
        return true; // Success
      } else {
        state = state.copyWith(error: 'Login failed: ${data.data['message']}');
        return false; // Failed
      }

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
      (ref) => AuthNotifier(),
);
