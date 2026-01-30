import '../../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final _dio = ApiService.dio;

  Future<DashboardModel> getSummary() async {
    final response = await _dio.get('${ApiConstants.baseUrl}/dashboard/summary');
    return DashboardModel.fromJson(response.data);
  }
}
