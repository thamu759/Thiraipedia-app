import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('Articles & Editorials',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Coming soon',
                style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
