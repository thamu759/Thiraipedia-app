import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_colors.dart';

class BlindFrameScreen extends StatefulWidget {
  const BlindFrameScreen({super.key});

  @override
  State<BlindFrameScreen> createState() => _BlindFrameScreenState();
}

class _BlindFrameScreenState extends State<BlindFrameScreen> {
  List<Movie> _candidates = [];
  final List<Movie> _used = [];
  Movie? _currentMovie;
  List<String> _options = [];
  String? _selected;
  bool _answered = false;
  int _score = 0;
  int _round = 0;
  final int _maxRounds = 5;
  bool _gameOver = false;
  final _rng = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_candidates.isEmpty && !_gameOver) _initGame();
  }

  void _initGame() {
    final movies = context.read<MovieProvider>().movies;
    if (movies.isEmpty) return;
    _candidates = movies.where((m) => m.posterUrl.isNotEmpty).toList()..shuffle(_rng);
    _used.clear();
    _round = 0;
    _score = 0;
    _gameOver = false;
    _nextRound();
  }

  void _nextRound() {
    if (_round >= _maxRounds) {
      setState(() => _gameOver = true);
      return;
    }
    if (_candidates.length < 5) {
      _candidates = List.from(_used)..shuffle(_rng);
      _used.clear();
    }
    final movie = _candidates.removeAt(0);
    _used.add(movie);
    final wrongPool = _candidates.where((m) => m.id != movie.id).toList()..shuffle(_rng);
    final wrongTitles = wrongPool.take(3).map((m) => m.title).toList();
    final all = [movie.title, ...wrongTitles]..shuffle(_rng);

    setState(() {
      _currentMovie = movie;
      _options = all;
      _selected = null;
      _answered = false;
    });
  }

  void _answer(String title) {
    if (_answered || _currentMovie == null) return;
    setState(() {
      _selected = title;
      _answered = true;
      if (title == _currentMovie!.title) _score++;
    });
  }

  void _next() {
    _round++;
    _nextRound();
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _score >= 4 ? Icons.emoji_events : _score >= 3 ? Icons.star : Icons.movie,
              color: AppColors.accent,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _score >= 4 ? 'Movie Master!' : _score >= 3 ? 'Good Eye!' : 'Keep Trying!',
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_score / $_maxRounds',
                style: const TextStyle(color: AppColors.accent, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text(
              _score >= 4
                  ? 'You really know your movies!'
                  : _score >= 3
                      ? 'Pretty good at identifying films!'
                      : 'Watch more movies and try again!',
              style: const TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initGame();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Play Again', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _currentMovie;

    if (_gameOver) {
      _showResult();
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          title: const Text('Blind Frame', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.bgDark,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Blind Frame', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.accent, size: 16),
                    const SizedBox(width: 6),
                    Text('$_score / $_maxRounds',
                        style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: movie == null
          ? const Center(
              child: Text('No movies available', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _maxRounds; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 28,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i < _round ? AppColors.accent : i == _round ? AppColors.accent.withValues(alpha: 0.5) : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Round ${_round + 1} of $_maxRounds',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 16),
                  Container(
                    width: 220,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.1), blurRadius: 20)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: 220,
                            height: 320,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppColors.bgCard,
                              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.bgCard,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                                  SizedBox(height: 8),
                                  Text('No poster', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
                                ],
                              ),
                            ),
                          ),
                          if (!_answered)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.blur_on, size: 60, color: Colors.white38),
                                          SizedBox(height: 12),
                                          Text('Blurred', style: TextStyle(color: Colors.white38, fontSize: 16, fontFamily: 'Poppins')),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_answered)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                                  ),
                                ),
                                child: Text(movie.title,
                                    style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_answered)
                    const Text('Choose the correct movie:',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  ..._options.map((title) {
                    final isSelected = _selected == title;
                    final isCorrect = title == movie.title;
                    Color? bg;
                    if (_answered) {
                      if (isCorrect) {
                        bg = const Color(0xFF1B5E20);
                      } else if (isSelected) {
                        bg = const Color(0xFFB71C1C);
                      }
                    }
                    return GestureDetector(
                      onTap: () => _answer(title),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: bg ?? (isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.bgCard),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected && !_answered
                                ? AppColors.accent
                                : isCorrect && _answered
                                    ? const Color(0xFF4CAF50)
                                    : isSelected && _answered
                                        ? const Color(0xFFEF5350)
                                        : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _answered && isCorrect ? Colors.greenAccent : Colors.white,
                                    fontFamily: 'Poppins',
                                  )),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22),
                            if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Color(0xFFEF5350), size: 22),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  if (_answered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _round + 1 >= _maxRounds ? 'See Results' : 'Next Movie',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
