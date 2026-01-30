import '../../core/constants/api_constants.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class ProfileRepository {
  final _dio = ApiService.dio;

  Future<List<ProfileModel>> getProfiles({int skip = 0, int limit = 100}) async {
    final response = await _dio.get(
      ApiConstants.profiles,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (response.data as List)
        .map((json) => ProfileModel.fromJson(json))
        .toList();
  }

  Future<ProfileModel> getProfile(int profileId) async {
    final response = await _dio.get('${ApiConstants.profiles}/$profileId');
    return ProfileModel.fromJson(response.data);
  }

  Future<ProfileModel> createProfile({
    required String name,
    String? relation,
    String? organization,
    String? phone,
    String? memo,
  }) async {
    final response = await _dio.post(
      ApiConstants.profiles,
      data: {
        'name': name,
        'relation': relation,
        'organization': organization,
        'phone': phone,
        'memo': memo,
      },
    );
    return ProfileModel.fromJson(response.data);
  }

  Future<ProfileModel> updateProfile(int profileId, {
    String? name,
    String? relation,
    String? organization,
    String? phone,
    String? memo,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (relation != null) data['relation'] = relation;
    if (organization != null) data['organization'] = organization;
    if (phone != null) data['phone'] = phone;
    if (memo != null) data['memo'] = memo;

    final response = await _dio.put(
      '${ApiConstants.profiles}/$profileId',
      data: data,
    );
    return ProfileModel.fromJson(response.data);
  }

  Future<void> deleteProfile(int profileId) async {
    await _dio.delete('${ApiConstants.profiles}/$profileId');
  }
}
