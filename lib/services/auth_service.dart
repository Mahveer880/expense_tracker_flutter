import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';

class AuthService {
  static final Box usersBox = Hive.box('users');
  static final Box sessionBox = Hive.box('session');

  // =====================================================
  // REGISTER USER
  // =====================================================

  static Future<bool> register(UserModel user) async {
    // Check if email already exists
    for (var item in usersBox.values) {
      final existingUser = UserModel.fromJson(Map<String, dynamic>.from(item));

      if (existingUser.email.toLowerCase() == user.email.toLowerCase()) {
        return false;
      }
    }

    await usersBox.add(user.toJson());
    return true;
  }

  // =====================================================
  // EMAIL / PASSWORD LOGIN
  // =====================================================

  static Future<UserModel?> login(String email, String password) async {
    for (var item in usersBox.values) {
      final user = UserModel.fromJson(Map<String, dynamic>.from(item));

      if (user.email.toLowerCase() == email.toLowerCase() &&
          user.password == password) {
        await sessionBox.put("currentUser", user.toJson());

        return user;
      }
    }

    return null;
  }

  // =====================================================
  // GOOGLE USER LOGIN / SAVE
  // =====================================================

  static Future<UserModel?> saveGoogleUser(UserModel user) async {
    try {
      dynamic existingKey;

      // Check whether this Google account already exists
      for (var key in usersBox.keys) {
        final item = usersBox.get(key);

        if (item == null) continue;

        final existingUser = UserModel.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (existingUser.id == user.id ||
            existingUser.email.toLowerCase() == user.email.toLowerCase()) {
          existingKey = key;
          break;
        }
      }

      // Existing Google user
      if (existingKey != null) {
        await usersBox.put(existingKey, user.toJson());
      } else {
        // New Google user
        await usersBox.add(user.toJson());
      }

      // Create current session
      await sessionBox.put("currentUser", user.toJson());

      return user;
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // CURRENT LOGGED-IN USER
  // =====================================================

  static UserModel? getCurrentUser() {
    final data = sessionBox.get("currentUser");

    if (data == null) {
      return null;
    }

    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    await sessionBox.delete("currentUser");
  }

  // =====================================================
  // IS LOGGED IN
  // =====================================================

  static bool isLoggedIn() {
    return sessionBox.get("currentUser") != null;
  }
}
