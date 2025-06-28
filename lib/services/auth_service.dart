class AuthService {
  static String? _token;
  static Map<String, dynamic>? _user;

  static void saveSession(String token, Map<String, dynamic> user) {
    _token = token;
    _user = user;
  }

  static void clearSession() {
    _token = null;
    _user = null;
  }

  static String? getToken() {
    return _token;
  }

  static Map<String, dynamic>? get user => _user;

  static bool get isLoggedIn => _token != null;
}
