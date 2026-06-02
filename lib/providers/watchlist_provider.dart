import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistProvider with ChangeNotifier {
  List<String> _movieIds = [];

  List<String> get movieIds => _movieIds;
  bool get isEmpty => _movieIds.isEmpty;
  int get count => _movieIds.length;

  Future<void> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('watchlist');
    if (data != null) {
      _movieIds = List<String>.from(jsonDecode(data));
      notifyListeners();
    }
  }

  Future<void> toggleMovie(String movieId) async {
    if (_movieIds.contains(movieId)) {
      _movieIds.remove(movieId);
    } else {
      _movieIds.add(movieId);
    }
    await _save();
    notifyListeners();
  }

  Future<void> toggleWatchlist(String movieId) async {
    await toggleMovie(movieId);
  }

  bool isInWatchlist(String movieId) => _movieIds.contains(movieId);

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('watchlist', jsonEncode(_movieIds));
  }
}
