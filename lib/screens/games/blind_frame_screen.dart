import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BlindFrameScreen extends StatefulWidget {
  const BlindFrameScreen({super.key});

  @override
  State<BlindFrameScreen> createState() => _BlindFrameScreenState();
}

class _BlindFrameScreenState extends State<BlindFrameScreen> {
  final _movies = [
    {'title': 'Inception', 'hint': 'Dream within a dream', 'emoji': '🌀'},
    {'title': 'The Dark Knight', 'hint': 'Why so serious?', 'emoji': '🦇'},
    {'title': 'Interstellar', 'hint': 'Murphys law', 'emoji': '🚀'},
    {'title': 'Parasite', 'hint': 'Rich and poor', 'emoji': '🏠'},
    {'title': 'Titanic', 'hint': 'King of the world', 'emoji': '🚢'},
    {'title': 'Joker', 'hint': 'Put on a happy face', 'emoji': '🤡'},
    {'title': 'The Matrix', 'hint': 'What is real?', 'emoji': '💊'},
    {'title': 'Forrest Gump', 'hint': 'Life is like a box of chocolates', 'emoji': '🍫'},
    {'title': 'Frozen', 'hint': 'Let it go', 'emoji': '❄️'},
    {'title': 'Harry Potter', 'hint': 'The boy who lived', 'emoji': '⚡'},
  ];

  int _current = 0;
  bool _revealed = false;
  final _controller = TextEditingController();
  int _score = 0;
  int _attempted = 0;
  String? _feedback;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final guess = _controller.text.trim().toLowerCase();
    if (guess.isEmpty) return;
    setState(() {
      _attempted++;
      _revealed = true;
      final correct = _movies[_current]['title'] as String;
      if (guess == correct.toLowerCase()) {
        _score++;
        _feedback = '✅ Correct!';
      } else {
        _feedback = '❌ Wrong!';
      }
    });
  }

  void _next() {
    setState(() {
      _current = (_current + 1) % _movies.length;
      _revealed = false;
      _controller.clear();
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movies[_current];
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Blind Frame', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('$_score/$_attempted', style: const TextStyle(color: AppColors.accent, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Movie ${_current + 1}/${_movies.length}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            Container(
              width: 220,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _revealed
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Center(
                child: _revealed
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(movie['emoji'] as String, style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 12),
                          Text(movie['title'] as String,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'Poppins')),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.blur_on, size: 80, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text('???', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.2), fontFamily: 'Poppins')),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text('Hint: ${movie['hint']}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 15, fontFamily: 'Poppins')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              enabled: !_revealed,
              onSubmitted: (_) => _checkAnswer(),
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: 'Guess the movie',
                labelStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
                hintText: 'Type your answer...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
                filled: true,
                fillColor: AppColors.bgCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
                suffixIcon: _revealed
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.check, color: AppColors.accent),
                        onPressed: _checkAnswer,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_feedback != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _feedback!.startsWith('✅') ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_feedback!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins')),
              ),
            if (_revealed) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_current < _movies.length - 1 ? 'Next Movie' : 'Start Over',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
