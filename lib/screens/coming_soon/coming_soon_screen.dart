import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upcoming,
                size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('Upcoming Movies',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Stay tuned for upcoming releases',
                style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
