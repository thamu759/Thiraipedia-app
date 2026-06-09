class ApiConfig {
  static const String baseUrl = 'https://cinevistaa.onrender.com';
  static const String apiUrl = '$baseUrl/api';

  static const Duration timeout = Duration(seconds: 30);

  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
  static const String tmdbApiBase = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey = 'cdef1e87093b92da3dcf8e7032daf61c';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}
