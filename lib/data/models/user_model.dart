class UserModel {
  final int id;
  final String email;
  final String name;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}
