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
    const Color(0xFFE57373), const Color(0xFFF06292),
    const Color(0xFFBA68C8), const Color(0xFF7986CB),
    const Color(0xFF64B5F6), const Color(0xFF4FC3F7),
    const Color(0xFF4DB6AC), const Color(0xFF81C784),
    const Color(0xFFAED581), const Color(0xFFFFD54F),
    const Color(0xFFFFB74D), const Color(0xFFA1887F),
    const Color(0xFFE57373), const Color(0xFFBA68C8),
    const Color(0xFF64B5F6), const Color(0xFF81C784),
  ];

  final _allMovies = [
    'Inception', 'Interstellar', 'The Dark Knight', 'Pulp Fiction',
    'Fight Club', 'The Matrix', 'Goodfellas', 'Parasite',
    'Whiplash', 'Joker', 'Avengers: Endgame', 'La La Land',
    'Shawshank Redemption', 'Spirited Away', 'Mad Max', 'RRR',
    'Vikram', 'The Batman', 'Dune', 'Oppenheimer',
  ];

  @override
  void initState() {
    super.initState();
    _shuffleMovies();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _spinAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _spinAnim.addListener(() {
      setState(() => _angle = _spinAnim.value * 2 * pi * (6 + _rng.nextDouble() * 3));
    });
  }

  void _shuffleMovies() {
    _movies = List.from(_allMovies)..shuffle(_rng);
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
          const SizedBox(height: 24),
          const Text('Tap SPIN to pick a random movie!',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: _spinning ? 0.3 : 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Wheel
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 290,
                      height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _WheelPainter(_movies, _segmentColors),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.6),
                                ],
                              ),
                              border: Border.all(color: Colors.white24, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.movie, size: 22, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Needle/pointer at top
                  Positioned(
                    top: -8,
                    child: Container(
                      width: 0,
                      height: 0,
                      child: CustomPaint(
                        painter: _NeedlePainter(),
                        size: const Size(40, 40),
                      ),
                    ),
                  ),
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
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _segmentColors[_winIndex! % _segmentColors.length],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.movie, size: 20, color: Colors.white),
                    ),
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
          const SizedBox(height: 24),
          // Spin button
          GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: _spinning ? 0.1 : 0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _spinning ? Icons.hourglass_top : Icons.casino,
                    color: Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _spinning ? 'Spinning...' : 'SPIN!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      letterSpacing: 1,
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

class _WheelPainter extends CustomPainter {
  final List<String> movies;
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
      final paint = Paint()..color = colors[i % colors.length];
      final startAngle = -pi / 2 + i * sweep;
      canvas.drawArc(rect, startAngle, sweep, true, paint);

      // Border line
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      final angle = startAngle;
      canvas.drawLine(
        center,
        Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius),
        linePaint,
      );

      // Draw text
      final textAngle = startAngle + sweep / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: movies[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.5);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);
      final tx = radius * 0.48;
      canvas.translate(tx - textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, ringPaint);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.movies.length != movies.length;
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 10, 0)
      ..lineTo(size.width / 2 + 10, 0)
      ..close();
    canvas.drawPath(path, paint);
    // Circle on top
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 6),
      5,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter old) => false;
}
