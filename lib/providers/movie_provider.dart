import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<Movie> _movies = [];
  List<Movie> _newReleases = [];
  Movie? _selectedMovie;
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  bool _searching = false;
  String? _error;

  String _selectedGenre = '';
  String _sortOption = 'rating';
  String _selectedOttPlatform = '';

  List<Movie> get movies => _movies;
  List<Movie> get newReleases => _newReleases;
  Movie? get selectedMovie => _selectedMovie;
  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get searching => _searching;
  String? get error => _error;

  String get selectedGenre => _selectedGenre;
  String get sortOption => _sortOption;
  String get selectedOttPlatform => _selectedOttPlatform;

  List<Movie> get heroMovies => _movies.where((m) => m.isHero).toList();
  List<Movie> get staffPicks => _movies.where((m) => m.isStaffPick).toList();
  List<Movie> get tamilMovies =>
      _movies.where((m) {
        final lang = m.language.toUpperCase();
        return lang == 'TA' || lang == 'TAMIL';
      }).toList();
  List<Movie> get malayalamMovies =>
      _movies.where((m) {
        final lang = m.language.toUpperCase();
        return lang == 'ML' || lang == 'MALAYALAM';
      }).toList();
  List<Movie> get topRatedMovies =>
      _movies.where((m) => m.rating >= 7).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

  List<Movie> get similarMovies {
    final genre = _selectedMovie?.genre ?? '';
    if (genre.isEmpty) return [];
    final genres = genre.split('/').map((g) => g.trim().toLowerCase());
    return _movies
        .where((m) =>
            m.id != _selectedMovie?.id &&
            genres.any((g) => m.genre.toLowerCase().contains(g)))
        .take(10)
        .toList();
  }

  Future<void> loadMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _movies = await _api.getMovies(
        genre: _selectedGenre.isNotEmpty ? _selectedGenre : null,
        sort: _sortOption,
        ottPlatform: _selectedOttPlatform.isNotEmpty ? _selectedOttPlatform : null,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNewReleases() async {
    try {
      final data = await _api.getMovies(sort: 'release-desc');
      _newReleases = data.where((m) => !m.isUpcoming).take(15).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMovieById(String id) async {
    _selectedMovie = null;
    notifyListeners();
    try {
      _selectedMovie = await _api.getMovieById(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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

  void setGenre(String genre) {
    _selectedGenre = genre;
    loadMovies();
  }

  void setSort(String sort) {
    _sortOption = sort;
    loadMovies();
  }

  void setOttPlatform(String platform) {
    _selectedOttPlatform = platform;
    loadMovies();
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
