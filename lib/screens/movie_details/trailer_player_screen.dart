// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_colors.dart';

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
  bool _injected = false;

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
        _inject();
      } else {
        html.window.open(widget.trailerUrl, '_blank');
        if (mounted) Navigator.pop(context);
      }
    });
  }

  void _remove() {
    html.document.getElementById(_containerId)?.remove();
  }

  void _inject() {
    if (_injected || _embedUrl == null) return;
    _injected = true;
    _remove();
    final container = html.DivElement()
      ..id = _containerId
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.zIndex = '9999'
      ..style.background = '#000';
    final closeBtn = html.DivElement()
      ..style.position = 'absolute'
      ..style.top = '16px'
      ..style.left = '16px'
      ..style.zIndex = '10000'
      ..style.width = '40px'
      ..style.height = '40px'
      ..style.background = 'rgba(0,0,0,0.6)'
      ..style.borderRadius = '12px'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.cursor = 'pointer'
      ..innerHtml = '<span style="color:white;font-size:24px;font-weight:700">&#x2715;</span>'
      ..onClick.listen((_) => _remove());
    final iframe = html.IFrameElement()
      ..src = _embedUrl!
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..allow = 'autoplay; encrypted-media; fullscreen'
      ..allowFullscreen = true;
    container.append(iframe);
    container.append(closeBtn);
    html.document.body?.append(container);
    if (mounted) Navigator.pop(context);
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
