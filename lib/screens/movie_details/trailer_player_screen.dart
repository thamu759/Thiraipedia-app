import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_colors.dart';
import '../../utils/html_utils.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String trailerUrl;
  final String title;

  const TrailerPlayerScreen({
    super.key,
    required this.trailerUrl,
    required this.title,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  static int _counter = 0;
  late final String _containerId;
  String? _embedUrl;

  String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host == 'youtu.be') {
      final id = uri.pathSegments.firstOrNull;
      if (id != null) return id;
    }
    final id = uri.queryParameters['v'];
    if (id != null) return id;
    return url;
  }

  @override
  void initState() {
    super.initState();
    _counter++;
    _containerId = 'trailer-overlay-$_counter';
    if (kIsWeb) {
      final id = _extractVideoId(widget.trailerUrl);
      if (id.length > 5 && id.length < 20) {
        _embedUrl = 'https://www.youtube.com/embed/$id?autoplay=1&rel=0&modestbranding=1';
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_embedUrl != null) {
        injectSimpleOverlay(containerId: _containerId, embedUrl: _embedUrl!);
        if (mounted) Navigator.pop(context);
      } else {
        openWindow(widget.trailerUrl, '_blank');
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 20),
            const Text('Opening trailer...',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}
