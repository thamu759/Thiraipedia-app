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
  double _angle = 0;
  String _result = '';
  bool _spinning = false;

  final _movies = [
    'Inception', 'Interstellar', 'The Dark Knight',
    'Pulp Fiction', 'Fight Club', 'The Matrix',
    'Goodfellas', 'Parasite', 'Whiplash', 'Joker',
    'Avengers: Endgame', 'La La Land', 'The Shawshank Redemption',
    'Spirited Away', 'Mad Max: Fury Road',
  ];

  final _segmentColors = [
    const Color(0xFFE57373), const Color(0xFF64B5F6),
    const Color(0xFF81C784), const Color(0xFFFFD54F),
    const Color(0xFFBA68C8), const Color(0xFF4DB6AC),
    const Color(0xFFF06292), const Color(0xFF4FC3F7),
    const Color(0xFFA1887F), const Color(0xFF7986CB),
    const Color(0xFFE57373), const Color(0xFF64B5F6),
    const Color(0xFF81C784), const Color(0xFFFFD54F),
    const Color(0xFFBA68C8),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() => _angle = _controller.value * 2 * pi * 6);
      });
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
    _controller.forward(from: 0).then((_) {
      final idx = Random().nextInt(_movies.length);
      setState(() {
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
        title: const Text('Spin the Wheel', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pick a random movie to watch!',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontFamily: 'Poppins')),
            const SizedBox(height: 24),
            Transform.rotate(
              angle: _angle,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: CustomPaint(
                  painter: _WheelPainter(_movies.length, _segmentColors),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgDark,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const Icon(Icons.movie, size: 28, color: AppColors.accent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Icon(Icons.arrow_drop_up, size: 40, color: AppColors.accent),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _spinning ? null : _spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.bgCard,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_spinning ? 'Spinning...' : 'SPIN!',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
            const SizedBox(height: 32),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Tonight you should watch:',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Text(_result,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'Poppins')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final int count;
  final List<Color> colors;

  _WheelPainter(this.count, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweep = 2 * pi / count;
    for (int i = 0; i < count; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(rect, -pi / 2 + i * sweep, sweep, true, paint);
      final linePaint = Paint()..color = Colors.black26..strokeWidth = 1;
      final angle = -pi / 2 + i * sweep;
      canvas.drawLine(Offset(size.width / 2, size.height / 2),
          Offset(size.width / 2 + cos(angle) * size.width / 2, size.height / 2 + sin(angle) * size.height / 2), linePaint);
    }
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, Paint()..color = Colors.black54);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.count != count;
}
