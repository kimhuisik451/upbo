import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final Dio _dio = ApiService.dio;

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );
    return UserModel.fromJson(response.data);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: 'username=$email&password=$password',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data);
  }
}
