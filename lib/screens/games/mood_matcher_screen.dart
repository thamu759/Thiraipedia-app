import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_colors.dart';

class MoodMatcherScreen extends StatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  State<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends State<MoodMatcherScreen> {
  String? _selectedMood;
  Movie? _recommendation;
  final _recommendedIds = <String>{};
  final _rng = Random();

  final _moods = {
    'Happy': {'emoji': '😊', 'desc': 'Light-hearted fun, feel-good films', 'tags': ['comedy', 'animation', 'musical']},
    'Sad': {'emoji': '😢', 'desc': 'Emotional, touching, heartfelt stories', 'tags': ['drama', 'tragedy', 'family']},
    'Excited': {'emoji': '🔥', 'desc': 'Action-packed, high-energy thrills', 'tags': ['action', 'thriller', 'adventure']},
    'Thoughtful': {'emoji': '🤔', 'desc': 'Mind-bending, thought-provoking plots', 'tags': ['sci-fi', 'mystery', 'psychological']},
    'Scared': {'emoji': '😨', 'desc': 'Spine-chilling horror and suspense', 'tags': ['horror', 'suspense', 'supernatural']},
    'Romantic': {'emoji': '❤️', 'desc': 'Love stories that warm your heart', 'tags': ['romance', 'rom-com', 'relationship']},
    'Motivated': {'emoji': '💪', 'desc': 'Inspiring stories of grit and triumph', 'tags': ['inspirational', 'biopic', 'sports']},
    'Bored': {'emoji': '😴', 'desc': 'Fast-paced fun to beat boredom', 'tags': ['comedy', 'adventure', 'fantasy']},
  };

  List<Movie> _getMoviesForMood(String mood) {
    final movies = context.read<MovieProvider>().movies;
    final tags = _moods[mood]!['tags'] as List<String>;
    final filtered = movies.where((m) {
      final genre = m.genre.toLowerCase();
      return tags.any((t) => genre.contains(t));
    }).toList();
    if (filtered.isEmpty) return movies; // fallback to all movies
    return filtered;
  }

  void _selectMood(String mood) {
    final candidates = _getMoviesForMood(mood)
        .where((m) => !_recommendedIds.contains(m.id) && m.posterUrl.isNotEmpty)
        .toList();

    if (candidates.isEmpty) {
      _recommendedIds.clear();
      final fresh = _getMoviesForMood(mood)
          .where((m) => m.posterUrl.isNotEmpty)
          .toList();
      if (fresh.isEmpty) return;
      setState(() {
        _selectedMood = mood;
        _recommendation = fresh[_rng.nextInt(fresh.length)];
        _recommendedIds.add(_recommendation!.id);
      });
      return;
    }

    final pick = candidates[_rng.nextInt(candidates.length)];
    setState(() {
      _selectedMood = mood;
      _recommendation = pick;
      _recommendedIds.add(pick.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMovies = context.watch<MovieProvider>().movies.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Mood Matcher',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.2),
                    AppColors.bgDark,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _recommendation != null ? (_moods[_selectedMood]!['emoji'] as String) : '🎬',
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Find Your Perfect Movie',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Text(
              _selectedMood != null
                  ? (_moods[_selectedMood]!['desc'] as String)
                  : 'Pick a mood and discover your next watch',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _moods.keys.map((mood) {
                final selected = _selectedMood == mood;
                final data = _moods[mood]!;
                return GestureDetector(
                  onTap: hasMovies ? () => _selectMood(mood) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(data['emoji'] as String, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(mood,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: selected ? Colors.black : Colors.white,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),
            if (_recommendation != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_moods[_selectedMood]!['emoji'] as String,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        const Text('Recommended for you',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Poster
                    if (_recommendation!.posterUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _recommendation!.posterUrl,
                          height: 200,
                          fit: BoxFit.contain,
                          placeholder: (_, _) => Container(
                            height: 200,
                            color: AppColors.bgDark,
                            child: const Center(
                                child: CircularProgressIndicator(color: AppColors.accent)),
                          ),
                          errorWidget: (_, _, _) => Container(
                            height: 200,
                            color: AppColors.bgDark,
                            child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(_recommendation!.title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                            fontFamily: 'Poppins'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_recommendation!.genre.toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(width: 8),
                        if (_recommendation!.rating > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.accent, size: 14),
                              const SizedBox(width: 2),
                              Text('${_recommendation!.rating}',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontFamily: 'Poppins')),
                            ],
                          ),
                        const SizedBox(width: 8),
                        Text('${_recommendation!.releaseYear}',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_recommendation!.description,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    if (_recommendedIds.length >= 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Seen ${_recommendedIds.length} recommendations!',
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontFamily: 'Poppins')),
                      ),
                  ],
                ),
              ),
            if (!hasMovies)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: const Text('Loading movies...',
                    style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
              ),
          ],
        ),
      ),
    );
  }
}
