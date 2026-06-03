import 'package:flutter/foundation.dart';
import '../models/community_thread.dart';
import '../services/api_service.dart';

class CommunityProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<CommunityThread> _threads = [];
  bool _loading = false;
  String? _error;

  List<CommunityThread> get threads => _threads;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchThreads() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _threads = await _api.getCommunityThreads();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createThread(
      {required String title,
      required String body,
      required String tag,
      required String token}) async {
    try {
      await _api.createCommunityThread(
          title: title, body: body, tag: tag, token: token);
      await fetchThreads();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addReply(String threadId,
      {required String body, String? token}) async {
    try {
      await _api.addCommunityReply(threadId, body: body, token: token);
      await fetchThreads();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
