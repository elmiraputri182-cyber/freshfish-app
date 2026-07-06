class UserModel {

  final String idUser;
  final String username;
  final String role;

  UserModel({
    required this.idUser,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'],
      username: json['username'],
      role: json['role'],
    );
  }
}