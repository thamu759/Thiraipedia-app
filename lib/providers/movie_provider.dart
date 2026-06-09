import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/cine_update.dart';
import '../services/api_service.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final TMDBService _tmdb = TMDBService();
  List<Movie> _movies = [];
  List<Movie> _newReleases = [];
  Movie? _selectedMovie;
  List<Movie> _searchResults = [];
  List<Movie> _similarMovies = [];
  final Map<String, String> _movieLogos = {};
  List<CineUpdate> _cineUpdates = [];
  bool _similarLoading = false;
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

  List<Movie> get similarMovies => _similarMovies;
  bool get similarLoading => _similarLoading;
  Map<String, String> get movieLogos => _movieLogos;
  List<CineUpdate> get cineUpdates => _cineUpdates;

  Future<void> loadMovieLogos(List<Movie> movies) async {
    for (final m in movies) {
      if (_movieLogos.containsKey(m.id)) continue;
      final tmdbId = m.tmdbId;
      if (tmdbId == null || tmdbId <= 0) continue;
      final logoUrl = await _tmdb.getMovieLogo(tmdbId);
      if (logoUrl != null) {
        _movieLogos[m.id] = logoUrl;
      }
    }
    notifyListeners();
  }

  Future<void> loadSimilarMovies() async {
    _similarLoading = true;
    _similarMovies = [];
    notifyListeners();
    final movie = _selectedMovie;
    if (movie == null) {
      _similarMovies = [];
      notifyListeners();
      return;
    }
    final genreStr = movie.genre;
    if (genreStr.isEmpty) {
      _similarMovies = [];
      notifyListeners();
      return;
    }
    final genres = genreStr
        .split(RegExp(r'[/,]'))
        .map((g) => g.trim().toLowerCase())
        .where((g) => g.isNotEmpty)
        .toList();
    if (genres.isEmpty) {
      _similarMovies = [];
      notifyListeners();
      return;
    }
    try {
      var pool = <Movie>[];
      for (final g in genres) {
        try {
          final results = await _api.getMovies(genre: g);
          pool.addAll(results);
        } catch (_) {}
      }
      if (pool.isEmpty) {
        pool = _movies.where((m) =>
            genres.any((g) => m.genre.toLowerCase().contains(g))).toList();
      }
      final seen = <String>{};
      final filtered = <Movie>[];
      for (final m in pool) {
        if (m.id == movie.id) continue;
        if (seen.contains(m.id)) continue;
        final mGenres = m.genre
            .split(RegExp(r'[/,]'))
            .map((g) => g.trim().toLowerCase())
            .toList();
        if (genres.any((g) => mGenres.contains(g))) {
          seen.add(m.id);
          filtered.add(m);
        }
      }
      filtered.sort((a, b) {
        final aSameLang = a.language.toUpperCase() == movie.language.toUpperCase() ? 1 : 0;
        final bSameLang = b.language.toUpperCase() == movie.language.toUpperCase() ? 1 : 0;
        if (aSameLang != bSameLang) return bSameLang.compareTo(aSameLang);
        final aGenreMatch = genres.where((g) =>
            a.genre.toLowerCase().contains(g)).length;
        final bGenreMatch = genres.where((g) =>
            b.genre.toLowerCase().contains(g)).length;
        if (aGenreMatch != bGenreMatch) return bGenreMatch.compareTo(aGenreMatch);
        return b.rating.compareTo(a.rating);
      });
      _similarMovies = filtered.take(10).toList();
    } catch (_) {
      _similarMovies = [];
    }
    _similarLoading = false;
    notifyListeners();
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
      final heroMovies = _movies.where((m) => m.isHero).toList();
      if (heroMovies.isNotEmpty) {
        loadMovieLogos(heroMovies);
      }
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
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCineUpdates() async {
    try {
      _cineUpdates = await _api.getCineUpdates();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMovieById(String id) async {
    _selectedMovie = null;
    _similarMovies = [];
    notifyListeners();
    try {
      _selectedMovie = await _api.getMovieById(id);
      if (_selectedMovie != null) {
        await loadSimilarMovies();
      }
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

  Future<void> setGenre(String genre) async {
    _selectedGenre = genre;
    await loadMovies();
  }

  Future<void> setSort(String sort) async {
    _sortOption = sort;
    await loadMovies();
  }

  Future<void> setOttPlatform(String platform) async {
    _selectedOttPlatform = platform;
    await loadMovies();
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

  @override
  void dispose() {
    _api.dispose();
    _tmdb.dispose();
    super.dispose();
  }
}
