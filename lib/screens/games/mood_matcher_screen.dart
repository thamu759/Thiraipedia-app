import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MoodMatcherScreen extends StatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  State<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends State<MoodMatcherScreen> {
  String? _selectedMood;
  String? _recommendation;
  String? _selectedEmoji;

  final _moods = {
    'Happy': {'emoji': '😊', 'movies': ['The Grand Budapest Hotel', 'La La Land', 'Zindagi Na Milegi Dobara', 'Paddington 2', 'Amélie', 'Toy Story']},
    'Sad': {'emoji': '😢', 'movies': ['The Green Mile', 'Grave of the Fireflies', '96', 'Manchester by the Sea', 'Coco', 'A Dog\'s Purpose']},
    'Excited': {'emoji': '🔥', 'movies': ['Mad Max: Fury Road', 'Avengers: Endgame', 'Vikram', 'Top Gun: Maverick', 'John Wick 4', 'RRR']},
    'Thoughtful': {'emoji': '🤔', 'movies': ['Inception', 'Interstellar', 'The Matrix', 'Shutter Island', 'Arrival', 'Predestination']},
    'Scared': {'emoji': '😨', 'movies': ['The Conjuring', 'Hereditary', 'Ratsasan', 'A Quiet Place', 'Get Out', 'The Ring']},
    'Romantic': {'emoji': '❤️', 'movies': ['The Notebook', 'Before Sunrise', 'OK Kanmani', 'Crazy Rich Asians', 'Eternal Sunshine', 'Pride & Prejudice']},
    'Motivated': {'emoji': '💪', 'movies': ['Rocky', 'The Pursuit of Happyness', 'Soorarai Pottru', 'Whiplash', 'Ford v Ferrari', '3 Idiots']},
    'Bored': {'emoji': '😴', 'movies': ['Everything Everywhere All at Once', 'The Wolf of Wall Street', 'KGF 2', 'Baby Driver', 'Catch Me If You Can', 'Zombieland']},
  };

  void _selectMood(String mood) {
    final data = _moods[mood]!;
    final movies = data['movies'] as List<String>;
    setState(() {
      _selectedMood = mood;
      _selectedEmoji = data['emoji'] as String;
      _recommendation = movies[Random().nextInt(movies.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Mood Matcher', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: Text(_selectedEmoji ?? '🎬', style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('How are you feeling?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            const Text('Pick a mood and get a movie recommendation',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _moods.keys.map((mood) {
                final selected = _selectedMood == mood;
                final data = _moods[mood]!;
                return GestureDetector(
                  onTap: () => _selectMood(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            const SizedBox(height: 40),
            if (_recommendation != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                        Text(_selectedEmoji ?? '', style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        const Text('We recommend:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_recommendation!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('for when you\'re feeling $_selectedMood',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
