import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'auth_service.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // =====================================================
  // INITIALIZE GOOGLE SIGN-IN
  // =====================================================

  static Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  // =====================================================
  // GOOGLE SIGN-IN
  // =====================================================

  static Future<UserModel?> signIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final user = UserModel(
        id: googleUser.id,
        name: googleUser.displayName ?? "Google User",
        email: googleUser.email,
        password: "",
        photoUrl: googleUser.photoUrl,
        loginType: "google",
      );

      final savedUser = await AuthService.saveGoogleUser(user);

      return savedUser;
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // GOOGLE SIGN-OUT
  // =====================================================

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await AuthService.logout();
  }
}
