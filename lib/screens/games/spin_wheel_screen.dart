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
  String _result = '';
  bool _spinning = false;
  int? _winIndex;
  List<String> _movies = [];
  final _rng = Random();

  final _segmentColors = [
    const Color(0xFFFF6B6B), const Color(0xFFFF8E53),
    const Color(0xFFFECA57), const Color(0xFF48DBFB),
    const Color(0xFF0ABDE3), const Color(0xFFA29BFE),
    const Color(0xFFFD79A8), const Color(0xFF6C5CE7),
    const Color(0xFF00B894), const Color(0xFF00CEC9),
    const Color(0xFFE17055), const Color(0xFF636E72),
    const Color(0xFFFF6B6B), const Color(0xFFFECA57),
    const Color(0xFF48DBFB), const Color(0xFFA29BFE),
  ];

  final _icons = [
    Icons.movie, Icons.star, Icons.play_arrow, Icons.favorite,
    Icons.flash_on, Icons.explore, Icons.rocket, Icons.auto_awesome,
    Icons.diamond, Icons.local_fire_department, Icons.whatshot, Icons.thunderstorm,
    Icons.movie_creation, Icons.videocam, Icons.theaters, Icons.live_tv,
  ];

  final _allMovies = [
    'Inception', 'Interstellar', 'The Dark Knight', 'Pulp Fiction',
    'Fight Club', 'The Matrix', 'Goodfellas', 'Parasite',
    'Whiplash', 'Joker', 'Avengers: Endgame', 'La La Land',
    'Shawshank Redemption', 'Spirited Away', 'Mad Max', 'RRR',
    'Vikram', 'The Batman', 'Dune', 'Oppenheimer',
    'The Godfather', 'Forrest Gump', 'Gladiator', 'Titanic',
  ];

  @override
  void initState() {
    super.initState();
    _shuffleMovies();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _spinAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _spinAnim.addListener(() {
      setState(() => _angle = _spinAnim.value * 2 * pi * (5 + _rng.nextDouble() * 4));
    });
  }

  void _shuffleMovies() {
    _movies = List.from(_allMovies)..shuffle(_rng);
    _movies = _movies.take(_rng.nextInt(4) + 8).toList();
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
    _controller.reset();
    _controller.forward().then((_) {
      final idx = _rng.nextInt(_movies.length);
      setState(() {
        _winIndex = idx;
        _result = _movies[idx];
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
          const SizedBox(height: 20),
          const Text('Tap SPIN to pick a random movie!',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 330,
                    height: 330,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: _spinning ? 0.25 : 0.1),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Decorative outer ring with dots
                  CustomPaint(
                    size: const Size(330, 330),
                    painter: _OuterRingPainter(),
                  ),
                  // The wheel
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _WheelPainter(_movies, _segmentColors, _icons),
                      ),
                    ),
                  ),
                  // Center hub with gradient
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      ),
                      border: Border.all(color: Colors.white54, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.star, size: 28, color: Colors.black87),
                  ),
                  // Needle with decoration
                  Positioned(
                    top: -6,
                    child: CustomPaint(
                      size: const Size(36, 48),
                      painter: _NeedlePainter(),
                    ),
                  ),
                  // Small decorative lights around the wheel
                  ...List.generate(12, (i) {
                    final a = i * (pi / 6);
                    return Positioned(
                      left: 165 + 155 * cos(a) - 5,
                      top: 165 + 155 * sin(a) - 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i.isEven ? AppColors.accent : Colors.white54,
                          boxShadow: [
                            BoxShadow(
                              color: (i.isEven ? AppColors.accent : Colors.white38).withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_winIndex != null)
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _segmentColors[_winIndex! % _segmentColors.length],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_icons[_winIndex! % _icons.length], size: 22, color: Colors.white),
                    ),
                  const SizedBox(width: 14),
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
          const SizedBox(height: 24),
          // Spin button
          GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: _spinning ? 0.1 : 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _spinning ? Icons.hourglass_top : Icons.casino,
                    color: Colors.black87,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _spinning ? 'Spinning...' : 'SPIN!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _OuterRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer gold ring
    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          AppColors.accent.withValues(alpha: 0.15),
          AppColors.accent.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.85, 0.92, 0.96, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(_OuterRingPainter old) => false;
}

class _WheelPainter extends CustomPainter {
  final List<String> movies;
  final List<Color> colors;
  final List<IconData> icons;

  _WheelPainter(this.movies, this.colors, this.icons);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final count = movies.length;
    final sweep = 2 * pi / count;

    for (int i = 0; i < count; i++) {
      final startAngle = -pi / 2 + i * sweep;

      // Draw segment with shadow
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);

      // Draw inner lighter highlight on each segment
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.85),
        startAngle, sweep, true, highlightPaint,
      );

      // Segment border
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1.5;
      final angle = startAngle;
      canvas.drawLine(
        center,
        Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius),
        linePaint,
      );

      // Draw text
      final textAngle = startAngle + sweep / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: movies[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.5);

      final tx = radius * 0.46;
      canvas.translate(tx - textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Inner ring
    final innerRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.78, innerRing);

    // Outer ring
    final outerRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 2, outerRing);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.movies.length != movies.length;
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path()
      ..moveTo(centerX, size.height - 2)
      ..lineTo(centerX - 12, 6)
      ..lineTo(centerX + 12, 6)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Needle body
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path()
      ..moveTo(centerX, size.height)
      ..lineTo(centerX - 10, 4)
      ..lineTo(centerX + 10, 4)
      ..close();
    canvas.drawPath(path, paint);

    // Needle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);

    // Tip circle
    canvas.drawCircle(
      Offset(centerX, size.height - 6),
      6,
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(
      Offset(centerX, size.height - 6),
      3,
      Paint()..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter old) => false;
}
