import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get user => _user;

  Future<void> checkAuthStatus() async {
    _isLoggedIn = await StorageService.hasToken();
    if (_isLoggedIn) {
      await fetchUser();
    }
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      _user = await _authRepository.getMe();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      await StorageService.saveToken(response.accessToken);
      _isLoggedIn = true;
      await fetchUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
