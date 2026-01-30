class ProfileModel {
  final int id;
  final String name;
  final String? relation;
  final String? organization;
  final String? phone;
  final String? memo;
  final String? profileImage;
  final DateTime? createdAt;
  final int totalLent;
  final int totalBorrowed;

  ProfileModel({
    required this.id,
    required this.name,
    this.relation,
    this.organization,
    this.phone,
    this.memo,
    this.profileImage,
    this.createdAt,
    this.totalLent = 0,
    this.totalBorrowed = 0,
  });

  int get totalDebt => totalLent - totalBorrowed;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: _parseInt(json['id']),
      name: json['name'],
      relation: json['relation'],
      organization: json['organization'],
      phone: json['phone'],
      memo: json['memo'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      totalLent: _parseInt(json['total_lent']),
      totalBorrowed: _parseInt(json['total_borrowed']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'organization': organization,
      'phone': phone,
      'memo': memo,
    };
  }
}
