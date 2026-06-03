import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  User? _profileUser;
  List<User> _users = [];
  bool _loading = false;
  String? _error;

  User? get profileUser => _profileUser;
  List<User> get users => _users;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchUser(String username) async {
    _loading = true;
    notifyListeners();
    try {
      _profileUser = await _api.getUserByUsername(username);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    try {
      _users = await _api.getUsers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> followUser(String username, {required String token}) async {
    await _api.followUser(username, token: token);
    if (_profileUser != null) {
      await fetchUser(_profileUser!.username);
    }
  }

  Future<void> unfollowUser(String username, {required String token}) async {
    await _api.unfollowUser(username, token: token);
    if (_profileUser != null) {
      await fetchUser(_profileUser!.username);
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
