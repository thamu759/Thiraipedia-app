import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TMDBService {
  final http.Client _client = http.Client();

  Future<String?> getMovieLogo(int tmdbId) async {
    if (tmdbId <= 0) return null;
    try {
      final url = '${ApiConfig.tmdbApiBase}/movie/$tmdbId/images'
          '?api_key=${ApiConfig.tmdbApiKey}';
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final logos = data['logos'] as List?;
      if (logos == null || logos.isEmpty) return null;
      final logoPath = logos[0]['file_path'] as String?;
      if (logoPath == null || logoPath.isEmpty) return null;
      return '${ApiConfig.tmdbImageBase}/w500$logoPath';
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
