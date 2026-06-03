import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _score = 0;
  int _current = 0;
  String? _selected;
  bool _answered = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  List<Map<String, dynamic>> _questions = [];
  int _totalQuestions = 10;
  int _streak = 0;

  final _pool = [
    {'q': 'Which film won the Best Picture Oscar in 2024?', 'options': ['Oppenheimer', 'Barbie', 'Killers of the Flower Moon', 'Poor Things', 'American Fiction'], 'answer': 'Oppenheimer'},
    {'q': 'Who directed "Interstellar"?', 'options': ['Christopher Nolan', 'Denis Villeneuve', 'Steven Spielberg', 'Ridley Scott', 'James Cameron'], 'answer': 'Christopher Nolan'},
    {'q': 'Which movie has the highest IMDb rating?', 'options': ['The Shawshank Redemption', 'The Godfather', 'The Dark Knight', 'Pulp Fiction', 'Schindlers List'], 'answer': 'The Shawshank Redemption'},
    {'q': 'Who played the Joker in "The Dark Knight"?', 'options': ['Heath Ledger', 'Jack Nicholson', 'Joaquin Phoenix', 'Jared Leto', 'Cesar Romero'], 'answer': 'Heath Ledger'},
    {'q': 'Which film is about dream sharing?', 'options': ['Inception', 'The Matrix', 'Avatar', 'Source Code', 'Paprika'], 'answer': 'Inception'},
    {'q': 'Highest-grossing film of all time?', 'options': ['Avatar', 'Avengers: Endgame', 'Titanic', 'Star Wars: TFA', 'Avatar 2'], 'answer': 'Avatar'},
    {'q': 'Who directed "Pulp Fiction"?', 'options': ['Quentin Tarantino', 'Martin Scorsese', 'David Fincher', 'Coen Brothers', 'Paul Thomas Anderson'], 'answer': 'Quentin Tarantino'},
    {'q': 'You cant handle the truth! - which movie?', 'options': ['A Few Good Men', 'The Verdict', 'Philadelphia', 'The Rainmaker', 'Primal Fear'], 'answer': 'A Few Good Men'},
    {'q': 'Who directed "Parasite" (2019)?', 'options': ['Bong Joon-ho', 'Park Chan-wook', 'Kim Ki-duk', 'Lee Chang-dong', 'Na Hong-jin'], 'answer': 'Bong Joon-ho'},
    {'q': 'Best Animated Feature Oscar 2024?', 'options': ['The Boy and the Heron', 'Spider-Man: Across the Spider-Verse', 'Elemental', 'Wish', 'Nimona'], 'answer': 'The Boy and the Heron'},
    {'q': 'In "The Matrix", what color pill does Neo take?', 'options': ['Red', 'Blue', 'Green', 'Yellow', 'Purple'], 'answer': 'Red'},
    {'q': 'Famous bench scene with piano music?', 'options': ['Forrest Gump', 'The Pursuit of Happyness', 'Good Will Hunting', 'Rain Man', 'The Terminal'], 'answer': 'Forrest Gump'},
    {'q': 'Who voiced Woody in "Toy Story"?', 'options': ['Tom Hanks', 'Tim Allen', 'Billy Crystal', 'John Goodman', 'Steve Buscemi'], 'answer': 'Tom Hanks'},
    {'q': 'First Best Picture Oscar winner?', 'options': ['Wings', 'Sunrise', 'The Broadway Melody', 'All Quiet on the Western Front', 'Sunset Blvd'], 'answer': 'Wings'},
    {'q': 'Fictional metal in "Black Panther"?', 'options': ['Vibranium', 'Adamantium', 'Mithril', 'Unobtainium', 'Uru'], 'answer': 'Vibranium'},
    {'q': 'Who directed "Schindlers List"?', 'options': ['Steven Spielberg', 'Roman Polanski', 'Stanley Kubrick', 'Michael Mann', 'David Lean'], 'answer': 'Steven Spielberg'},
    {'q': 'Which film won Best Picture in 2023?', 'options': ['Everything Everywhere All at Once', 'The Fabelmans', 'Top Gun: Maverick', 'All Quiet on the Western Front', 'Elvis'], 'answer': 'Everything Everywhere All at Once'},
    {'q': 'Who played Wolverine in X-Men?', 'options': ['Hugh Jackman', 'Ryan Reynolds', 'Chris Evans', 'James Marsden', 'Patrick Stewart'], 'answer': 'Hugh Jackman'},
    {'q': 'Which movie has the quote "Here is looking at you, kid"?', 'options': ['Casablanca', 'Gone with the Wind', 'Citizen Kane', 'The Maltese Falcon', 'Sunset Boulevard'], 'answer': 'Casablanca'},
    {'q': 'What year was the first "Toy Story" released?', 'options': ['1995', '1994', '1996', '1997', '1993'], 'answer': '1995'},
    {'q': 'Who directed "Goodfellas"?', 'options': ['Martin Scorsese', 'Francis Ford Coppola', 'Brian De Palma', 'Sergio Leone', 'Michael Mann'], 'answer': 'Martin Scorsese'},
    {'q': 'Which actor has played James Bond the most times?', 'options': ['Roger Moore', 'Sean Connery', 'Pierce Brosnan', 'Daniel Craig', 'Timothy Dalton'], 'answer': 'Roger Moore'},
    {'q': 'What is the highest-rated Indian film on IMDb?', 'options': ['KGF 2', 'RRR', 'Vikram', 'Baahubali 2', '3 Idiots'], 'answer': 'RRR'},
    {'q': 'Which movie features the song "Naatu Naatu"?', 'options': ['RRR', 'Baahubali 2', 'Pushpa', 'KGF 2', 'Vikram'], 'answer': 'RRR'},
    {'q': 'Who played Iron Man in the MCU?', 'options': ['Robert Downey Jr.', 'Chris Evans', 'Chris Hemsworth', 'Mark Ruffalo', 'Jeremy Renner'], 'answer': 'Robert Downey Jr.'},
    {'q': 'Which film won the Palme d\'Or in 2024?', 'options': ['Anora', 'The Zone of Interest', 'Anatomy of a Fall', 'Perfect Days', 'Fallen Leaves'], 'answer': 'Anora'},
    {'q': 'Who directed "The Godfather"?', 'options': ['Francis Ford Coppola', 'Martin Scorsese', 'Steven Spielberg', 'Sergio Leone', 'Stanley Kubrick'], 'answer': 'Francis Ford Coppola'},
    {'q': 'Which movie is based on a theme park ride?', 'options': ['Pirates of the Caribbean', 'Jumanji', 'The Haunted Mansion', 'Tomorrowland', 'Jungle Cruise'], 'answer': 'Pirates of the Caribbean'},
    {'q': 'Who played the Riddler in "The Batman" (2022)?', 'options': ['Paul Dano', 'Colin Farrell', 'John Turturro', 'Andy Serkis', 'Jeffrey Wright'], 'answer': 'Paul Dano'},
    {'q': 'Which film has the most Oscar wins ever?', 'options': ['Titanic', 'Ben-Hur', 'The Lord of the Rings: ROTK', 'West Side Story', 'Gigi'], 'answer': 'Titanic'},
    {'q': 'Who directed "Kill Bill"?', 'options': ['Quentin Tarantino', 'Robert Rodriguez', 'John Woo', 'Park Chan-wook', 'Eli Roth'], 'answer': 'Quentin Tarantino'},
    {'q': 'Which movie introduced the character "Hannibal Lecter"?', 'options': ['The Silence of the Lambs', 'Manhunter', 'Red Dragon', 'Hannibal', 'Se7en'], 'answer': 'Manhunter'},
    {'q': 'What is the fictional continent in "Game of Thrones"?', 'options': ['Westeros', 'Essos', 'Middle-earth', 'Narnia', 'Pandora'], 'answer': 'Westeros'},
    {'q': 'Who played Katniss Everdeen in "The Hunger Games"?', 'options': ['Jennifer Lawrence', 'Emma Stone', 'Shailene Woodley', 'Saoirse Ronan', 'Kirsten Dunst'], 'answer': 'Jennifer Lawrence'},
    {'q': 'Which movie features a character named "Frodo Baggins"?', 'options': ['The Lord of the Rings', 'The Hobbit', 'The Chronicles of Narnia', 'Harry Potter', 'Willow'], 'answer': 'The Lord of the Rings'},
    {'q': 'Who directed "The Social Network"?', 'options': ['David Fincher', 'Aaron Sorkin', 'Mark Zuckerberg', 'Ben Affleck', 'Steven Soderbergh'], 'answer': 'David Fincher'},
    {'q': 'Which film won Best Picture in 2020?', 'options': ['Parasite', '1917', 'Joker', 'Once Upon a Time in Hollywood', 'The Irishman'], 'answer': 'Parasite'},
    {'q': 'Who played the Genie in Aladdin (2019)?', 'options': ['Will Smith', 'Robin Williams', 'Jimmy Fallon', 'Dan Castellaneta', 'Gilbert Gottfried'], 'answer': 'Will Smith'},
    {'q': 'Which movie has a character named "Truman" whos in a TV show?', 'options': ['The Truman Show', 'Ed TV', 'Pleasantville', 'Showtime', 'Stranger than Fiction'], 'answer': 'The Truman Show'},
    {'q': 'Who directed "Mad Max: Fury Road"?', 'options': ['George Miller', 'James Cameron', 'Ridley Scott', 'Zack Snyder', 'Peter Jackson'], 'answer': 'George Miller'},
    {'q': 'Which movie features the song "My Heart Will Go On"?', 'options': ['Titanic', 'Romeo + Juliet', 'The Bodyguard', 'Armageddon', 'Pearl Harbor'], 'answer': 'Titanic'},
    {'q': 'What is the name of the fictional planet in "Avatar"?', 'options': ['Pandora', 'Endor', 'Tatooine', 'Krypton', 'Asgard'], 'answer': 'Pandora'},
    {'q': 'Who played Jack Sparrow in "Pirates of the Caribbean"?', 'options': ['Johnny Depp', 'Orlando Bloom', 'Geoffrey Rush', 'Tom Cruise', 'Brad Pitt'], 'answer': 'Johnny Depp'},
    {'q': 'Which movie is based on the novel by Stephen King?', 'options': ['The Shawshank Redemption', 'The Green Mile', 'The Shining', 'Misery', 'All of the above'], 'answer': 'All of the above'},
    {'q': 'Who directed "Django Unchained"?', 'options': ['Quentin Tarantino', 'Spike Lee', 'John Ford', 'Clint Eastwood', 'Steve McQueen'], 'answer': 'Quentin Tarantino'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initQuestions();
  }

  void _initQuestions() {
    final shuffled = List<Map<String, dynamic>>.from(_pool)..shuffle(Random());
    _questions = shuffled.take(_totalQuestions).toList();
    for (final q in _questions) {
      final opts = List<String>.from(q['options'] as List<String>);
      opts.shuffle(Random());
      q['options'] = opts;
    }
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
      if (option == _questions[_current]['answer']) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
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
    final pct = _score / _questions.length;
    String title;
    IconData icon;
    if (pct >= 0.9) {
      title = 'Cinema Legend!';
      icon = Icons.emoji_events;
    } else if (pct >= 0.7) {
      title = 'Film Buff!';
      icon = Icons.star;
    } else if (pct >= 0.5) {
      title = 'Not Bad!';
      icon = Icons.thumb_up;
    } else {
      title = 'Keep Watching!';
      icon = Icons.movie;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_score / ${_questions.length}',
                style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text(
                _streak >= 5
                    ? '🔥 $_streak streak! Amazing!'
                    : 'Best streak: $_streak',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(
              pct >= 0.9
                  ? 'You are a true movie master!'
                  : pct >= 0.7
                      ? 'Great movie knowledge!'
                      : pct >= 0.5
                          ? 'Room for improvement!'
                          : 'Time to binge more movies!',
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _current = 0;
                _score = 0;
                _streak = 0;
                _selected = null;
                _answered = false;
              });
              _initQuestions();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Play Again',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
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
        title: const Text('Movie Quiz',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_current + 1} / ${_questions.length}',
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontFamily: 'Poppins')),
                Row(
                  children: [
                    if (_streak >= 3)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('$_streak',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                      ),
                    Text('$_score',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700)),
                    Text(' / ${_questions.length}',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                  ],
                ),
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
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_current),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(q['q'] as String,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        height: 1.4),
                    textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 20),
            ...(q['options'] as List<String>).map((opt) {
              final isSelected = _selected == opt;
              final isCorrect = opt == q['answer'];
              Color? bg;
              Color? borderColor;
              Widget? suffix;
              if (_answered) {
                if (isCorrect) {
                  bg = const Color(0xFF1B5E20);
                  borderColor = const Color(0xFF4CAF50);
                  suffix = const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 22);
                } else if (isSelected) {
                  bg = const Color(0xFFB71C1C);
                  borderColor = const Color(0xFFEF5350);
                  suffix = const Icon(Icons.cancel,
                      color: Color(0xFFEF5350), size: 22);
                }
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 10),
                key: ValueKey('$opt-${_current}'),
                child: GestureDetector(
                  onTap: () => _answer(opt),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg ??
                          (isSelected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.bgCard),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor ??
                            (isSelected ? AppColors.accent : AppColors.border),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _answered && isCorrect
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  fontFamily: 'Poppins')),
                        ),
                        if (suffix != null) suffix,
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _current < _questions.length - 1
                          ? 'Next'
                          : 'Results',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
