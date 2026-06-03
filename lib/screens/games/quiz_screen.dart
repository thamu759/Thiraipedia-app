import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  int _current = 0;
  String? _selected;
  bool _answered = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final _questions = [
    {'q': 'Which film won the Best Picture Oscar in 2024?', 'options': ['Oppenheimer', 'Barbie', 'Killers of the Flower Moon', 'Poor Things'], 'answer': 'Oppenheimer'},
    {'q': 'Who directed "Interstellar"?', 'options': ['Christopher Nolan', 'Denis Villeneuve', 'Steven Spielberg', 'Ridley Scott'], 'answer': 'Christopher Nolan'},
    {'q': 'Which movie has the highest IMDb rating?', 'options': ['The Shawshank Redemption', 'The Godfather', 'The Dark Knight', 'Pulp Fiction'], 'answer': 'The Shawshank Redemption'},
    {'q': 'Who played the Joker in "The Dark Knight"?', 'options': ['Jack Nicholson', 'Heath Ledger', 'Joaquin Phoenix', 'Jared Leto'], 'answer': 'Heath Ledger'},
    {'q': 'Which film is set in the world of "dream sharing"?', 'options': ['Inception', 'The Matrix', 'Avatar', 'Source Code'], 'answer': 'Inception'},
    {'q': 'What is the highest-grossing film of all time?', 'options': ['Avengers: Endgame', 'Avatar', 'Titanic', 'Star Wars: TFA'], 'answer': 'Avatar'},
    {'q': 'Who directed "Pulp Fiction"?', 'options': ['Martin Scorsese', 'Quentin Tarantino', 'David Fincher', 'Coen Brothers'], 'answer': 'Quentin Tarantino'},
    {'q': 'Which movie features the line "You cant handle the truth!"?', 'options': ['A Few Good Men', 'The Verdict', 'Philadelphia', 'The Rainmaker'], 'answer': 'A Few Good Men'},
    {'q': 'Who directed "Parasite" (2019)?', 'options': ['Park Chan-wook', 'Bong Joon-ho', 'Kim Ki-duk', 'Lee Chang-dong'], 'answer': 'Bong Joon-ho'},
    {'q': 'Which animated film won Best Animated Feature Oscar 2024?', 'options': ['Spider-Man: Across the Spider-Verse', 'Elemental', 'The Boy and the Heron', 'Wish'], 'answer': 'The Boy and the Heron'},
    {'q': 'In "The Matrix", what color pill does Neo take?', 'options': ['Blue', 'Red', 'Green', 'Yellow'], 'answer': 'Red'},
    {'q': 'Which film features a famous "bench" scene with piano music?', 'options': ['Forrest Gump', 'The Pursuit of Happyness', 'Good Will Hunting', 'Rain Man'], 'answer': 'Forrest Gump'},
    {'q': 'Who voiced Woody in "Toy Story"?', 'options': ['Tom Hanks', 'Tim Allen', 'Billy Crystal', 'John Goodman'], 'answer': 'Tom Hanks'},
    {'q': 'Which movie won the first Best Picture Oscar?', 'options': ['Wings', 'Sunrise', 'The Broadway Melody', 'All Quiet on the Western Front'], 'answer': 'Wings'},
    {'q': 'What is the fictional metal in "Black Panther"?', 'options': ['Adamantium', 'Vibranium', 'Mithril', 'Unobtainium'], 'answer': 'Vibranium'},
    {'q': 'Who directed "Schindlers List"?', 'options': ['Steven Spielberg', 'Roman Polanski', 'Stanley Kubrick', 'Michael Mann'], 'answer': 'Steven Spielberg'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _answer(String option) {
    if (_answered) return;
    setState(() {
      _selected = option;
      _answered = true;
      if (option == _questions[_current]['answer']) _score++;
    });
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
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
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_score >= _questions.length * 0.7 ? Icons.emoji_events : Icons.star, color: AppColors.accent, size: 28),
            const SizedBox(width: 10),
            Text(_score >= _questions.length * 0.7 ? 'Amazing!' : 'Quiz Complete!', style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: $_score/${_questions.length}', style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text(_score >= _questions.length * 0.7 ? 'Great knowledge!' : _score >= _questions.length * 0.4 ? 'Keep watching!' : 'Time to watch more movies!', style: TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'Poppins')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _current = 0;
                _score = 0;
                _selected = null;
                _answered = false;
              });
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
    final q = _questions[_current];
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Movie Quiz', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_current + 1}/${_questions.length}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                Text('Score: $_score', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_current + 1) / _questions.length,
                color: AppColors.accent,
                backgroundColor: AppColors.bgCard,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(q['q'] as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins', height: 1.4),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            ...(q['options'] as List<String>).map((opt) {
              final isSelected = _selected == opt;
              final isCorrect = opt == q['answer'];
              Color? bg;
              Color? borderColor;
              IconData? icon;
              if (_answered) {
                if (isCorrect) {
                  bg = const Color(0xFF1B5E20);
                  borderColor = const Color(0xFF4CAF50);
                  icon = Icons.check_circle;
                } else if (isSelected) {
                  bg = const Color(0xFFB71C1C);
                  borderColor = const Color(0xFFEF5350);
                  icon = Icons.cancel;
                }
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _answer(opt),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg ?? (isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.bgCard),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor ?? (isSelected ? AppColors.accent : AppColors.border), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _answered && isCorrect ? Colors.greenAccent : Colors.white, fontFamily: 'Poppins')),
                        ),
                        if (icon != null) Icon(icon, color: isCorrect ? Colors.greenAccent : Colors.redAccent, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              ScaleTransition(
                scale: _pulseAnim,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_current < _questions.length - 1 ? 'Next Question' : 'See Results',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
