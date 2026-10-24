import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  // Singleton Pattern
  static final SecureStorageHelper instance = SecureStorageHelper.internal();

  factory SecureStorageHelper() => instance;

  SecureStorageHelper.internal();

  final storage = const FlutterSecureStorage();

  // =========================
  // Keys
  // =========================

  static const String accessTokenKey = 'token';
  static const String refreshTokenKey = 'refreshToken';
  static const String expiresAtKey = 'expiresOn';
  static const String refreshTokenExpiresOnKey = 'refreshTokenExpiresOn';

  static const String userTypeKey = 'userType';

  static const String userNameKey = 'userName';
  static const String profilePicKey = 'profilePic';
  static const String userIdKey = 'userId';
  static const String emailKey = 'email';
  static const String whatsAppKey = 'whatsAppNumber';
  static const String countryKey = 'country';

  // =========================
  // Save Tokens
  // =========================

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
    required String refreshTokenExpiresOn,
  }) async {
    await storage.write(key: accessTokenKey, value: accessToken);

    await storage.write(key: refreshTokenKey, value: refreshToken);

    await storage.write(key: expiresAtKey, value: expiresAt);

    await storage.write(
      key: refreshTokenExpiresOnKey,
      value: refreshTokenExpiresOn,
    );
  }

  // =========================
  // Save User Type
  // =========================

  Future<void> saveUserType(String userType) async {
    await storage.write(key: userTypeKey, value: userType);
  }

  Future<String?> getUserType() async {
    return await storage.read(key: userTypeKey);
  }

  // =========================
  // Save User Data
  // =========================

  Future<void> saveUserData({
    required String userName,
    required String profilePic,
    required String userId,
    required String email,
    required String whatsAppNumber,
    required String country,
  }) async {
    await storage.write(key: userNameKey, value: userName);

    await storage.write(key: profilePicKey, value: profilePic);

    await storage.write(key: userIdKey, value: userId);

    await storage.write(key: emailKey, value: email);

    await storage.write(key: whatsAppKey, value: whatsAppNumber);

    await storage.write(key: countryKey, value: country);
  }

  // =========================
  // Get User Data
  // =========================

  Future<String?> getUserName() async {
    return await storage.read(key: userNameKey);
  }

  Future<String?> getProfilePic() async {
    return await storage.read(key: profilePicKey);
  }

  Future<String?> getUserId() async {
    return await storage.read(key: userIdKey);
  }

  Future<String?> getEmail() async {
    return await storage.read(key: emailKey);
  }

  Future<String?> getWhatsAppNumber() async {
    return await storage.read(key: whatsAppKey);
  }

  Future<String?> getCountry() async {
    return await storage.read(key: countryKey);
  }

  // =========================
  // Role Mapping
  // =========================

  // =========================
  // Get Tokens
  // =========================

  Future<String?> getAccessToken() async {
    return await storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: refreshTokenKey);
  }

  Future<String?> getExpiresAt() async {
    return await storage.read(key: expiresAtKey);
  }

  Future<String?> getRefreshTokenExpiresAt() async {
    return await storage.read(key: refreshTokenExpiresOnKey);
  }

  // =========================
  // Logout
  // =========================

  Future<void> clearTokens() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);

    await storage.delete(key: expiresAtKey);

    await storage.delete(key: refreshTokenExpiresOnKey);

    await storage.delete(key: userTypeKey);

    await storage.delete(key: userNameKey);
    await storage.delete(key: profilePicKey);
    await storage.delete(key: userIdKey);
    await storage.delete(key: emailKey);
    await storage.delete(key: whatsAppKey);
    await storage.delete(key: countryKey);
  }

  // =========================
  // Check Login
  // =========================

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }
}
