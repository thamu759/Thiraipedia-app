import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MoodMatcherScreen extends StatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  State<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends State<MoodMatcherScreen> {
  String? _selectedMood;
  String? _recommendation;

  final _moods = {
    'Happy': ['The Grand Budapest Hotel', 'La La Land', 'Zindagi Na Milegi Dobara'],
    'Sad': ['The Green Mile', 'Grave of the Fireflies', '96'],
    'Excited': ['Mad Max: Fury Road', 'Avengers: Endgame', 'Vikram'],
    'Thoughtful': ['Inception', 'Interstellar', 'The Matrix'],
    'Scared': ['The Conjuring', 'Hereditary', 'Ratsasan'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Matcher')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('How are you feeling?',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.keys.map((mood) {
                final selected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                      final movies = _moods[mood]!;
                      _recommendation =
                          movies[DateTime.now().millisecondsSinceEpoch %
                              movies.length];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(mood,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            if (_recommendation != null) ...[
              const Text('We recommend:',
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Text(_recommendation!,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
