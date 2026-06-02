import 'package:flutter/foundation.dart';
import '../models/list_model.dart';
import '../services/api_service.dart';

class ListProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<MovieList> _lists = [];
  bool _loading = false;
  String? _error;

  List<MovieList> get lists => _lists;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchLists({String? username}) async {
    _loading = true;
    notifyListeners();
    try {
      _lists = await _api.getLists(username: username);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createList(
      {required String name,
      required String description,
      required String token}) async {
    try {
      await _api.createList(name: name, description: description, token: token);
      await fetchLists();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMovieToList(String listId, String movieId,
      {required String token}) async {
    await _api.addMovieToList(listId, movieId, token: token);
    await fetchLists();
  }

  Future<void> removeMovieFromList(String listId, String movieId,
      {required String token}) async {
    await _api.removeMovieFromList(listId, movieId, token: token);
    await fetchLists();
  }

  Future<void> deleteList(String listId, {required String token}) async {
    await _api.deleteList(listId, token: token);
    await fetchLists();
  }
}
