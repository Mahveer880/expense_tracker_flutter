class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? photoUrl;
  final String loginType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl,
    this.loginType = "email",
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "photoUrl": photoUrl,
      "loginType": loginType,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      photoUrl: json["photoUrl"],
      loginType: json["loginType"] ?? "email",
    );
  }
}
