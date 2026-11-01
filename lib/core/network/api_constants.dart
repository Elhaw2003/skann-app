class EndPoint {
  static const String baseUrl = 'https://sakann.duckdns.org/api/v1/';
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
  static const String properties = 'properties';
  static const String locations = 'locations';
  static const String amenities = 'amenities';
  static const String myProfile = 'users/me';
  static const String myPassword = 'users/me/password';
  static const String roommates = 'users/roommates';
}

class ApiKey {
  static const String statusCode = 'statusCode';
  static const String tokenPrefix = 'Bearer';
}
