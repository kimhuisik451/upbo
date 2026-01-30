import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class ApiService {
  static Dio? _dio;
  
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // 디버그용 로그
        print('🔹 Request: ${options.method} ${options.path}');
        print('🔹 Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.response?.statusCode} - ${error.message}');
        return handler.next(error);
      },
    ));

    return dio;
  }

  static void init() {
    // dio getter에서 자동 초기화됨
    _dio ??= _createDio();
  }
}
