class UserModel {
  final String email;
  final String nickname;

  UserModel({required this.email, required this.nickname});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'nickname': nickname};
  }
}
