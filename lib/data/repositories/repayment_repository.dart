import '../../core/constants/api_constants.dart';
import '../models/repayment_model.dart';
import '../services/api_service.dart';

class RepaymentRepository {
  final _dio = ApiService.dio;

  /// 상환 목록 조회
  Future<List<RepaymentModel>> getRepayments({
    required int debtId,
    int skip = 0,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      ApiConstants.repayments,
      queryParameters: {
        'debt_id': debtId,
        'skip': skip,
        'limit': limit,
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => RepaymentModel.fromJson(json)).toList();
  }

  /// 상환 등록
  Future<RepaymentModel> createRepayment({
    required int debtId,
    required int amount,
    required DateTime repaymentDate,
    String? memo,
  }) async {
    final response = await _dio.post(
      ApiConstants.repayments,
      data: {
        'debt_id': debtId,
        'amount': amount,
        'repayment_date': repaymentDate.toUtc().toIso8601String(),
        'memo': memo,
      },
    );
    return RepaymentModel.fromJson(response.data);
  }

  /// 상환 삭제
  Future<void> deleteRepayment(int repaymentId) async {
    await _dio.delete('${ApiConstants.repayments}/$repaymentId');
  }
}
