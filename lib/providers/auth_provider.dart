import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        _user = await _api.getMe(token);
        notifyListeners();
      } catch (_) {
        await prefs.remove('token');
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.login(username, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String username, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.register(username, email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    _user = await _api.updateProfile(data: data, token: _user!.token);
    notifyListeners();
  }

  String get token => _user?.token ?? '';
}
