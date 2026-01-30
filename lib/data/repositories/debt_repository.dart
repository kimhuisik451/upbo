import '../../core/constants/api_constants.dart';
import '../models/debt_model.dart';
import '../services/api_service.dart';

class DebtRepository {
  final _dio = ApiService.dio;

  /// 채무 목록 조회
  /// 모든 파라미터는 선택사항
  Future<List<DebtModel>> getDebts({
    int? profileId,
    String? transactionType, // "lent" | "borrowed"
    bool? isSettled,
    int skip = 0,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (profileId != null) queryParams['profile_id'] = profileId;
    if (transactionType != null) queryParams['transaction_type'] = transactionType;
    if (isSettled != null) queryParams['is_settled'] = isSettled;
    queryParams['skip'] = skip;
    queryParams['limit'] = limit;

    final response = await _dio.get(
      ApiConstants.debts,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => DebtModel.fromJson(json)).toList();
  }

  /// 채무 상세 조회
  Future<DebtModel> getDebt(int debtId) async {
    final response = await _dio.get('${ApiConstants.debts}/$debtId');
    return DebtModel.fromJson(response.data);
  }

  Future<DebtModel> createDebt({
    required int profileId,
    required String transactionType,
    required int amount,
    String? category,
    String? memo,
    required DateTime transactionDate,
  }) async {
    final response = await _dio.post(
      ApiConstants.debts,
      data: {
        'profile_id': profileId,
        'transaction_type': transactionType,
        'amount': amount,
        'category': category,
        'memo': memo,
        'transaction_date': transactionDate.toUtc().toIso8601String(),
      },
    );
    return DebtModel.fromJson(response.data);
  }

  /// 채무 수정
  Future<DebtModel> updateDebt({
    required int debtId,
    String? category,
    String? memo,
    bool? isSettled,
  }) async {
    final data = <String, dynamic>{};
    if (category != null) data['category'] = category;
    if (memo != null) data['memo'] = memo;
    if (isSettled != null) data['is_settled'] = isSettled;

    final response = await _dio.put(
      '${ApiConstants.debts}/$debtId',
      data: data,
    );
    return DebtModel.fromJson(response.data);
  }

  /// 채무 삭제
  Future<void> deleteDebt(int debtId) async {
    await _dio.delete('${ApiConstants.debts}/$debtId');
  }
}
