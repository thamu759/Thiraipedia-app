import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('thiraipedia',
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            SizedBox(height: 8),
            Text('Premium Film Critique & Reviews',
                style: TextStyle(color: AppTheme.textMuted)),
            SizedBox(height: 24),
            Text(
              'ThiraiPedia is built for movie enthusiasts who believe cinema is more than entertainment. We provide a platform for honest, curated reviews and thoughtful critique.',
              style: TextStyle(color: AppTheme.textMuted, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'From the latest blockbusters to regional cinema in Tamil and Malayalam, our community rates and reviews films across languages and genres.',
              style: TextStyle(color: AppTheme.textMuted, height: 1.5),
            ),
            SizedBox(height: 24),
            Text('Powered by TMDB',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
