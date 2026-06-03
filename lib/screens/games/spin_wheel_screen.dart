import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spinAnim;
  double _angle = 0;
  double _targetTurns = 0;
  String _result = '';
  bool _spinning = false;
  int? _winIndex;
  late List<MovieEntry> _movies;
  final _rng = Random();

  final _pool = [
    MovieEntry('Inception', '🌀'), MovieEntry('Interstellar', '🚀'),
    MovieEntry('The Dark Knight', '🦇'), MovieEntry('Pulp Fiction', '🔫'),
    MovieEntry('Fight Club', '👊'), MovieEntry('The Matrix', '💊'),
    MovieEntry('Goodfellas', '🍝'), MovieEntry('Parasite', '🏠'),
    MovieEntry('Whiplash', '🥁'), MovieEntry('Joker', '🤡'),
    MovieEntry('Avengers', '⚡'), MovieEntry('La La Land', '🎵'),
    MovieEntry('Shawshank', '⛓️'), MovieEntry('Spirited Away', '👻'),
    MovieEntry('Mad Max', '🔥'), MovieEntry('RRR', '🇮🇳'),
    MovieEntry('Dune', '🏜️'), MovieEntry('Oppenheimer', '☢️'),
    MovieEntry('Godfather', '🍷'), MovieEntry('Forrest Gump', '🍫'),
    MovieEntry('Titanic', '🚢'), MovieEntry('Gladiator', '⚔️'),
  ];

  final _segmentColors = [
    const Color(0xFFFF4757), const Color(0xFFFF6B81),
    const Color(0xFFFFA502), const Color(0xFFFFDA79),
    const Color(0xFF2ED573), const Color(0xFF7BED9F),
    const Color(0xFF1E90FF), const Color(0xFF70A1FF),
    const Color(0xFFA29BFE), const Color(0xFFD980FA),
    const Color(0xFFFD79A8), const Color(0xFFE17055),
    const Color(0xFF00CEC9), const Color(0xFF55E6C1),
    const Color(0xFFFF4757), const Color(0xFFFFA502),
    const Color(0xFF1E90FF), const Color(0xFFA29BFE),
    const Color(0xFF2ED573), const Color(0xFFFD79A8),
    const Color(0xFF00CEC9), const Color(0xFFE17055),
  ];

  @override
  void initState() {
    super.initState();
    _shuffleMovies();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _spinAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _spinAnim.addListener(() {
      setState(() => _angle = _spinAnim.value * 2 * pi * _targetTurns);
    });
  }

  void _shuffleMovies() {
    _movies = List.from(_pool)..shuffle(_rng);
    _movies = _movies.take(_rng.nextInt(3) + 8).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    _spinning = true;
    _result = '';
    _winIndex = null;
    _targetTurns = 6 + _rng.nextDouble() * 4;
    _angle = 0;
    _controller.reset();
    _controller.forward().then((_) {
      final idx = _rng.nextInt(_movies.length);
      setState(() {
        _winIndex = idx;
        _result = _movies[idx].name;
        _spinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Spin the Wheel',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('⭐ Tap SPIN to pick a random movie! ⭐',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins', letterSpacing: 0.5)),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: _spinning ? 0.3 : 0.12),
                          blurRadius: 70,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  // Outer decorative ring
                  CustomPaint(
                    size: const Size(350, 350),
                    painter: _OuterRingPainter(_spinning),
                  ),
                  // Wheel
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 25, spreadRadius: 8),
                        ],
                      ),
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _WheelPainter(_movies, _segmentColors),
                      ),
                    ),
                  ),
                  // Center hub
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFF176), Color(0xFFFFB300)],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 3),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎬', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  // Needle
                  Positioned(
                    top: -2,
                    child: CustomPaint(
                      size: const Size(34, 52),
                      painter: _NeedlePainter(),
                    ),
                  ),
                  // Decorative sparkle lights
                  ...List.generate(16, (i) {
                    final a = i * (pi / 8);
                    final isStar = i % 2 == 0;
                    return Positioned(
                      left: 175 + 158 * cos(a) - (isStar ? 8 : 5),
                      top: 175 + 158 * sin(a) - (isStar ? 8 : 5),
                      child: isStar
                          ? Text('✨', style: TextStyle(fontSize: 14, color: AppColors.accent.withValues(alpha: 0.7)))
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.6),
                                boxShadow: [BoxShadow(color: Colors.white38, blurRadius: 6)],
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Result card
          if (_result.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _winIndex != null
                    ? _segmentColors[_winIndex! % _segmentColors.length].withValues(alpha: 0.2)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _winIndex != null
                      ? _segmentColors[_winIndex! % _segmentColors.length]
                      : AppColors.accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_winIndex != null)
                    Text(_movies[_winIndex!].emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('You should watch:',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Poppins')),
                      Text(_result,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Spin button
          GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              width: 170,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF176), Color(0xFFFF8F00), Color(0xFFFF6F00)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: _spinning ? 0.2 : 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_spinning ? '⏳' : '🎰', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    _spinning ? 'Spinning...' : 'SPIN!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class MovieEntry {
  final String name;
  final String emoji;
  const MovieEntry(this.name, this.emoji);
}

class _OuterRingPainter extends CustomPainter {
  final bool spinning;
  const _OuterRingPainter(this.spinning);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow ring
    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.orange.withValues(alpha: spinning ? 0.2 : 0.1),
          Colors.yellow.withValues(alpha: spinning ? 0.1 : 0.05),
          Colors.transparent,
        ],
        stops: const [0.82, 0.9, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, ringPaint);

    // Outer circles decoration
    for (int i = 0; i < 20; i++) {
      final a = i * (pi / 10);
      final x = center.dx + radius * 0.88 * cos(a);
      final y = center.dy + radius * 0.88 * sin(a);
      canvas.drawCircle(
        Offset(x, y),
        i.isEven ? 3 : 2,
        Paint()..color = Colors.white.withValues(alpha: i.isEven ? 0.5 : 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_OuterRingPainter old) => old.spinning != spinning;
}

class _WheelPainter extends CustomPainter {
  final List<MovieEntry> movies;
  final List<Color> colors;

  _WheelPainter(this.movies, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final count = movies.length;
    final sweep = 2 * pi / count;

    for (int i = 0; i < count; i++) {
      final startAngle = -pi / 2 + i * sweep;

      // Segment fill
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);

      // Segment highlight arc
      final hlPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.82),
        startAngle, sweep, true, hlPaint,
      );

      // Segment border
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 2;
      final angle = startAngle;
      canvas.drawLine(
        center,
        Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius),
        linePaint,
      );

      // Text
      final textAngle = startAngle + sweep / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      // Emoji
      final emojiPainter = TextPainter(
        text: TextSpan(text: movies[i].emoji, style: const TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(radius * 0.32 - emojiPainter.width / 2, -emojiPainter.height / 2 - 6);
      emojiPainter.paint(canvas, Offset.zero);
      canvas.restore();

      // Name
      final namePainter = TextPainter(
        text: TextSpan(
          text: movies[i].name,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 4),
              Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(1, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.38);

      canvas.save();
      canvas.translate(radius * 0.42 - namePainter.width / 2, -namePainter.height / 2 + 8);
      namePainter.paint(canvas, Offset.zero);
      canvas.restore();
      canvas.restore();
    }

    // Outer ring
    canvas.drawCircle(center, radius - 2, Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);

    // Inner ring
    canvas.drawCircle(center, radius * 0.25, Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.movies.length != movies.length;
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Shadow
    canvas.save();
    canvas.translate(2, 2);
    final sp = Paint()..color = Colors.black.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final sPath = Path()
      ..moveTo(cx, size.height)
      ..lineTo(cx - 10, 4)
      ..lineTo(cx + 10, 4)
      ..close();
    canvas.drawPath(sPath, sp);
    canvas.restore();

    // Needle body
    final gp = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF176), Color(0xFFFF8F00), Color(0xFFFF6F00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path()
      ..moveTo(cx, size.height)
      ..lineTo(cx - 9, 2)
      ..lineTo(cx + 9, 2)
      ..close();
    canvas.drawPath(path, gp);

    // Border
    canvas.drawPath(path, Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // Tip circle
    canvas.drawCircle(Offset(cx, size.height - 4), 7, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(Offset(cx, size.height - 4), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, size.height - 4), 2, Paint()..color = const Color(0xFFFF6F00));
  }

  @override
  bool shouldRepaint(_NeedlePainter old) => false;
}
