import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://res.cloudinary.com/di0j4psxz/video/upload/v1780421526/Yellow_lines_form_abstract_shapes_202606022251_homgfq.mp4',
      ),
    );

    _controller.initialize().then((_) {
      if (mounted) {
        _controller.play();
        setState(() {});
      }
    }).catchError((_) {
      if (mounted) _goToHome();
    });

    _controller.addListener(() {
      if (_controller.value.isCompleted && mounted) {
        _goToHome();
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) _goToHome();
    });
  }

  void _goToHome() {
    if (_navigated) return;
    _navigated = true;
    _controller.removeListener(() {});
    _controller.pause();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _goToHome,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Skip ›',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
