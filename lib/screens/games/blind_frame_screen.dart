import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BlindFrameScreen extends StatefulWidget {
  const BlindFrameScreen({super.key});

  @override
  State<BlindFrameScreen> createState() => _BlindFrameScreenState();
}

class _BlindFrameScreenState extends State<BlindFrameScreen> {
  final _movies = [
    {'title': 'Inception', 'hint': 'Dream within a dream'},
    {'title': 'The Dark Knight', 'hint': 'Why so serious?'},
    {'title': 'Interstellar', 'hint': 'Murphys law'},
    {'title': 'Parasite', 'hint': 'Rich and poor'},
  ];

  int _current = 0;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final movie = _movies[_current];
    return Scaffold(
      appBar: AppBar(title: const Text('Blind Frame')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _revealed
                  ? const Center(
                      child: Icon(Icons.movie,
                          size: 80, color: AppTheme.primaryColor))
                  : const Center(
                      child: Icon(Icons.blur_on,
                          size: 80, color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 20),
            Text('Hint: ${movie['hint']}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              onChanged: (_) {},
              decoration: InputDecoration(
                labelText: 'Guess the movie',
                hintText: 'Type your answer...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    setState(() => _revealed = true);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_revealed) ...[
              Text('Answer: ${movie['title']}',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _current = (_current + 1) % _movies.length;
                    _revealed = false;
                  });
                },
                child: const Text('Next'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
