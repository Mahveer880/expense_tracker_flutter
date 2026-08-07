import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';

class AuthService {
  static final Box usersBox = Hive.box('users');
  static final Box sessionBox = Hive.box('session');

  // Register User
  static Future<bool> register(UserModel user) async {
    // Check if email already exists
    for (var item in usersBox.values) {
      final existingUser = UserModel.fromJson(Map<String, dynamic>.from(item));

      if (existingUser.email == user.email) {
        return false;
      }
    }

    await usersBox.add(user.toJson());
    return true;
  }

  // Login User
  static Future<UserModel?> login(String email, String password) async {
    for (var item in usersBox.values) {
      final user = UserModel.fromJson(Map<String, dynamic>.from(item));

      if (user.email == email && user.password == password) {
        await sessionBox.put("currentUser", user.toJson());
        return user;
      }
    }

    return null;
  }

  // Current Logged In User
  static UserModel? getCurrentUser() {
    final data = sessionBox.get("currentUser");

    if (data == null) return null;

    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  // Logout
  static Future<void> logout() async {
    await sessionBox.delete("currentUser");
  }

  // Is Logged In
  static bool isLoggedIn() {
    return sessionBox.get("currentUser") != null;
  }
}
