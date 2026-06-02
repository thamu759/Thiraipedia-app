import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Movie> _movies = [];
  List<Movie> _heroMovies = [];
  List<Movie> _staffPicks = [];
  Movie? _selectedMovie;
  List<Movie> _searchResults = [];
  bool _loading = false;
  String? _error;
  bool _searching = false;

  List<Movie> get movies => _movies;
  List<Movie> get heroMovies => _heroMovies;
  List<Movie> get staffPicks => _staffPicks;
  Movie? get selectedMovie => _selectedMovie;
  List<Movie> get searchResults => _searchResults;
  bool get loading => _loading;
  String? get error => _error;
  bool get searching => _searching;

  Future<void> fetchMovies({
    String? search,
    String? genre,
    String? sort,
    String? ottPlatform,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _movies = await _api.getMovies(
          search: search, genre: genre, sort: sort, ottPlatform: ottPlatform);
      _heroMovies = _movies.where((m) => m.isHero).toList();
      _staffPicks = _movies.where((m) => m.isStaffPick).toList();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMovieById(String id) async {
    _loading = true;
    notifyListeners();
    try {
      _selectedMovie = await _api.getMovieById(id);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searching = false;
      notifyListeners();
      return;
    }
    _searching = true;
    notifyListeners();
    try {
      _searchResults = await _api.getMovies(search: query);
      _searching = false;
      notifyListeners();
    } catch (e) {
      _searching = false;
      notifyListeners();
    }
  }

  Future<void> addReview(String movieId,
      {required double rating,
      required String text,
      required String token}) async {
    _selectedMovie =
        await _api.addReview(movieId, rating: rating, text: text, token: token);
    notifyListeners();
  }

  Future<void> toggleLike(String movieId, String reviewId,
      {required String token}) async {
    _selectedMovie = await _api.toggleReviewLike(movieId, reviewId, token: token);
    notifyListeners();
  }

  Future<void> addReviewReply(String movieId, String reviewId,
      {required String body, required String token}) async {
    _selectedMovie = await _api.addReviewReply(movieId, reviewId,
        body: body, token: token);
    notifyListeners();
  }
}
