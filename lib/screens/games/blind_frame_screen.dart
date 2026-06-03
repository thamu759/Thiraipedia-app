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
  int _total = 0;
  final _rng = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_candidates.isEmpty) _initGame();
  }

  void _initGame() {
    final movies = context.read<MovieProvider>().movies;
    if (movies.isEmpty) return;
    _candidates = movies.where((m) => m.posterUrl.isNotEmpty).toList()..shuffle(_rng);
    _used.clear();
    _nextRound();
  }

  void _nextRound() {
    if (_candidates.isEmpty) {
      setState(() {
        _currentMovie = null;
      });
      return;
    }
    final movie = _candidates.removeAt(0);
    _used.add(movie);
    final wrong = _candidates
      ..shuffle(_rng);
    final wrongTitles = wrong.take(3).map((m) => m.title).toList();
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
      _total++;
      if (title == _currentMovie!.title) _score++;
    });
  }

  void _next() {
    if (_candidates.length < 4) _candidates = List.from(_used)..shuffle(_rng);
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    final movie = _currentMovie;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Blind Frame',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
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
                    Text('$_score / $_total',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: movie == null
          ? const Center(
              child: Text('No movies available',
                  style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Can you identify this movie?',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 20),
                  // Blurred poster
                  Container(
                    width: 220,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
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
                                  Text('No poster',
                                      style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
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
                                          Text('Blurred',
                                              style: TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins')),
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
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                                child: Text(movie.title,
                                    style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
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
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontFamily: 'Poppins')),
                  const SizedBox(height: 12),
                  // Options
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
                          color: bg ?? (isSelected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.bgCard),
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
                                    color: _answered && isCorrect
                                        ? Colors.greenAccent
                                        : Colors.white,
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Next Movie',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins')),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
