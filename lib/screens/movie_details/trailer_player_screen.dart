import 'package:flutter/material.dart';
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
  late final String _containerId;

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
    _containerId = 'trailer-${DateTime.now().millisecondsSinceEpoch}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _extractVideoId(widget.trailerUrl);
      if (id.length > 5 && id.length < 20) {
        final embedUrl =
            'https://www.youtube.com/embed/$id?autoplay=1&rel=0&modestbranding=1';
        showTrailerPopup(
          context: context,
          embedUrl: embedUrl,
          containerId: _containerId,
          adVideoUrl: '',
          setState: (fn) {},
        );
      } else {
        openWindow(widget.trailerUrl, '_blank');
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
