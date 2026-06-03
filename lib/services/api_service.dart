import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/user.dart';
import '../models/community_thread.dart';
import '../models/list_model.dart';

class ApiService {
  static void Function()? onUnauthorized;
  final http.Client _client = http.Client();

  Future<dynamic> _get(String path, {String? token}) async {
    final headers = token != null
        ? ApiConfig.authHeaders(token)
        : ApiConfig.headers;
    final response = await _client
        .get(Uri.parse('${ApiConfig.apiUrl}$path'), headers: headers)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> _post(String path,
      {Map<String, dynamic>? body, String? token}) async {
    final headers = token != null
        ? ApiConfig.authHeaders(token)
        : ApiConfig.headers;
    final response = await _client
        .post(Uri.parse('${ApiConfig.apiUrl}$path'),
            headers: headers, body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> _put(String path,
      {Map<String, dynamic>? body, String? token}) async {
    final headers = token != null
        ? ApiConfig.authHeaders(token)
        : ApiConfig.headers;
    final response = await _client
        .put(Uri.parse('${ApiConfig.apiUrl}$path'),
            headers: headers, body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> _delete(String path,
      {String? token}) async {
    final headers = token != null
        ? ApiConfig.authHeaders(token)
        : ApiConfig.headers;
    final response = await _client
        .delete(Uri.parse('${ApiConfig.apiUrl}$path'), headers: headers)
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return jsonDecode(response.body);
    }
    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw UnauthorizedException();
    }
    try {
      final body = jsonDecode(response.body);
      throw ApiException(body['error'] ?? 'Something went wrong');
    } catch (e) {
      if (e is ApiException || e is UnauthorizedException) rethrow;
      throw ApiException('Server error (${response.statusCode})');
    }
  }

  List<Movie> _parseMovies(dynamic data) {
    if (data is List) return data.map((m) => Movie.fromJson(m)).toList();
    return [];
  }

  Future<List<Movie>> getMovies({
    String? search,
    String? genre,
    String? sort,
    String? ottPlatform,
  }) async {
    final params = <String, String>{};
    if (search != null) params['search'] = search;
    if (genre != null) params['genre'] = genre;
    if (sort != null) params['sort'] = sort;
    if (ottPlatform != null) params['ottPlatform'] = ottPlatform;
    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    final result = await _get('/movies$query');
    return _parseMovies(result);
  }

  Future<Movie> getMovieById(String id) async {
    final result = await _get('/movies/$id');
    return Movie.fromJson(result as Map<String, dynamic>);
  }

  Future<List<Movie>> getMoviesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final result = await _get('/movies/batch?ids=${ids.join(',')}');
    return _parseMovies(result);
  }

  Future<Movie> addReview(String movieId,
      {required double rating,
      required String text,
      required String token}) async {
    final result = await _post('/movies/$movieId/reviews',
        body: {'rating': rating, 'text': text}, token: token);
    return Movie.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deleteReview(String movieId, String reviewId,
      {required String token}) async {
    await _delete('/movies/$movieId/reviews/$reviewId', token: token);
  }

  Future<Movie> toggleReviewLike(String movieId, String reviewId,
      {required String token}) async {
    final result = await _post('/movies/$movieId/reviews/$reviewId/like',
        token: token);
    return Movie.fromJson(result as Map<String, dynamic>);
  }

  Future<Movie> addReviewReply(String movieId, String reviewId,
      {required String body, required String token}) async {
    final result = await _post(
        '/movies/$movieId/reviews/$reviewId/replies',
        body: {'body': body},
        token: token);
    return Movie.fromJson(result as Map<String, dynamic>);
  }

  Future<User> register(
      String username, String email, String password) async {
    final result = await _post('/auth/register', body: {
      'username': username,
      'email': email,
      'password': password,
    });
    return User.fromJson(result as Map<String, dynamic>);
  }

  Future<User> login(String username, String password) async {
    final result = await _post('/auth/login', body: {
      'username': username,
      'password': password,
    });
    return User.fromJson(result as Map<String, dynamic>);
  }

  Future<User> getMe(String token) async {
    final result = await _get('/auth/me', token: token);
    return User.fromJson(result as Map<String, dynamic>);
  }

  Future<List<CommunityThread>> getCommunityThreads() async {
    final result = await _get('/community/threads');
    if (result is List) {
      return result.map((t) => CommunityThread.fromJson(t as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CommunityThread> createCommunityThread(
      {required String title,
      required String body,
      required String tag,
      String? token}) async {
    final result = await _post('/community/threads',
        body: {'title': title, 'body': body, 'tag': tag}, token: token);
    return CommunityThread.fromJson(result as Map<String, dynamic>);
  }

  Future<CommunityThread> addCommunityReply(String threadId,
      {required String body, String? token}) async {
    final result = await _post('/community/threads/$threadId/replies',
        body: {'body': body}, token: token);
    return CommunityThread.fromJson(result as Map<String, dynamic>);
  }

  Future<User> getUserByUsername(String username) async {
    final result = await _get('/users/$username');
    return User.fromJson(result as Map<String, dynamic>);
  }

  Future<List<User>> getUsers() async {
    final result = await _get('/users');
    if (result is List) {
      return result.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<User> updateProfile(
      {required Map<String, dynamic> data, required String token}) async {
    final result = await _put('/users/profile', body: data, token: token);
    return User.fromJson(result as Map<String, dynamic>);
  }

  Future<void> followUser(String username, {required String token}) async {
    await _post('/users/$username/follow', token: token);
  }

  Future<void> unfollowUser(String username, {required String token}) async {
    await _delete('/users/$username/follow', token: token);
  }

  Future<List<MovieList>> getLists({String? username}) async {
    final query = username != null ? '?username=$username' : '';
    final result = await _get('/lists$query');
    if (result is List) {
      return result.map((l) => MovieList.fromJson(l as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<MovieList> createList(
      {required String name,
      required String description,
      required String token}) async {
    final result = await _post('/lists',
        body: {'name': name, 'description': description}, token: token);
    return MovieList.fromJson(result as Map<String, dynamic>);
  }

  Future<MovieList> addMovieToList(String listId, String movieId,
      {required String token}) async {
    final result = await _post('/lists/$listId/movies',
        body: {'movieId': movieId}, token: token);
    return MovieList.fromJson(result as Map<String, dynamic>);
  }

  Future<void> removeMovieFromList(String listId, String movieId,
      {required String token}) async {
    await _delete('/lists/$listId/movies/$movieId', token: token);
  }

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final result = await _post('/auth/send-otp', body: {'email': email});
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(
      {required String email, required String otp}) async {
    final result = await _post('/auth/verify-otp',
        body: {'email': email, 'otp': otp});
    return result as Map<String, dynamic>;
  }

  Future<void> deleteList(String listId, {required String token}) async {
    await _delete('/lists/$listId', token: token);
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final result = await _get('/leaderboard');
    if (result is List) {
      return result.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getPageContent(String page) async {
    final result = await _get('/pages/$page');
    return result as Map<String, dynamic>;
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired. Please sign in again.';
}
