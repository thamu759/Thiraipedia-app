import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _current = 0;
  String? _selected;
  bool _answered = false;

  final _questions = [
    {
      'q': 'Which film won the Best Picture Oscar in 2024?',
      'options': ['Oppenheimer', 'Barbie', 'Killers of the Flower Moon', 'Poor Things'],
      'answer': 'Oppenheimer',
    },
    {
      'q': 'Who directed "Interstellar"?',
      'options': ['Christopher Nolan', 'Denis Villeneuve', 'Steven Spielberg', 'Ridley Scott'],
      'answer': 'Christopher Nolan',
    },
    {
      'q': 'Which movie has the highest IMDb rating?',
      'options': ['The Shawshank Redemption', 'The Godfather', 'The Dark Knight', 'Pulp Fiction'],
      'answer': 'The Shawshank Redemption',
    },
  ];

  void _answer(String option) {
    if (_answered) return;
    setState(() {
      _selected = option;
      _answered = true;
      if (option == _questions[_current]['answer']) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Quiz Complete!'),
        content: Text(
            'Your score: $_score/${_questions.length}'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _current = 0;
                _score = 0;
                _selected = null;
                _answered = false;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Question ${_current + 1}/${_questions.length}',
                style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_current + 1) / _questions.length,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
            ),
            const SizedBox(height: 32),
            Text(q['q'] as String,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ...(q['options'] as List<String>).map((opt) {
              final isSelected = _selected == opt;
              final isCorrect = opt == q['answer'];
              Color? bg;
              if (_answered) {
                bg = isCorrect
                    ? AppTheme.successColor
                    : (isSelected ? AppTheme.primaryColor : null);
              }
              return GestureDetector(
                onTap: () => _answer(opt),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bg ?? AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryColor)
                        : null,
                  ),
                  child: Text(opt,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_current < _questions.length - 1
                      ? 'Next'
                      : 'See Results'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
