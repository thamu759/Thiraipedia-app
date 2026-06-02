class ApiConfig {
  static const String baseUrl = 'https://cinevistaa.onrender.com';
  static const String apiUrl = '$baseUrl/api';

  static const Duration timeout = Duration(seconds: 30);

  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}
