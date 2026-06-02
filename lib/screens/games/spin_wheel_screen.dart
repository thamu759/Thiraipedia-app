import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() => _angle = _controller.value * 2 * pi * 5);
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
      appBar: AppBar(title: const Text('Spin the Wheel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: _angle,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.primaryColor, width: 3),
                  gradient: const RadialGradient(colors: [
                    AppTheme.surfaceColor,
                    AppTheme.cardColor,
                  ]),
                ),
                child: const Center(
                  child: Icon(Icons.movie,
                      size: 60, color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _spinning ? null : _spin,
              child: Text(_spinning ? 'Spinning...' : 'Spin!'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Text('Watch: $_result',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }
}
