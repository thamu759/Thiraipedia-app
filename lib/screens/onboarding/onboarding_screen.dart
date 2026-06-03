import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  final _pages = [
    const _PageData(
      icon: Icons.movie_creation_rounded,
      title: 'Thiraipedia',
      subtitle: 'Your complete guide to Tamil cinema',
      desc: 'Discover movies, read reviews, watch trailers, and stay updated with the latest releases all in one place.',
    ),
    const _PageData(
      icon: Icons.explore_rounded,
      title: 'Browse & Explore',
      subtitle: '200+ movies at your fingertips',
      desc: 'Filter by genre, language, rating, or OTT platform. Find staff picks, top rated, and hidden gems you will love.',
    ),
    const _PageData(
      icon: Icons.auto_awesome_rounded,
      title: 'Fun Activities',
      subtitle: 'Quiz, Card Flix, Blind Frame & more',
      desc: 'Test your movie knowledge, swipe through mystery cards, guess films from blurred posters, or find one by your mood.',
    ),
    const _PageData(
      icon: Icons.rocket_launch_rounded,
      title: '',
      subtitle: '',
      desc: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();

    _pageController.addListener(() {
      final page = (_pageController.page ?? 0).round();
      if (page != _currentPage) {
        setState(() => _currentPage = page);
        _slideController.reset();
        _slideController.forward();
      }
    });
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildIconArea(int index, _PageData page, bool isFirst) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(6, (i) {
          final a = (i * pi / 3) + (index * 0.2);
          final dist = 90.0 + sin(index * 0.5 + i) * 20;
          return Positioned(
            left: 140 + cos(a) * dist - 8,
            top: 140 + sin(a) * dist - 8,
            child: Opacity(
              opacity: 0.2 + (sin(i * 2.3 + index) * 0.08).abs(),
              child: Icon(
                [Icons.star_rounded, Icons.circle, Icons.square_rounded,
                 Icons.diamond_rounded, Icons.star_rounded, Icons.circle][i],
                size: 14 + (i % 3) * 6,
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
          );
        }),
        SlideTransition(
          position: _slideAnim,
          child: isFirst
              ? Image.asset('assets/logo.png', height: 140, fit: BoxFit.contain)
              : Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.2),
                        AppColors.accent.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(page.icon, color: AppColors.accent, size: 44),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildReadyPage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(6, (i) {
          final a = (i * pi / 3);
          final dist = 100.0;
          return Positioned(
            left: 140 + cos(a) * dist - 10,
            top: 140 + sin(a) * dist - 10,
            child: Icon(
              [Icons.star_rounded, Icons.circle, Icons.diamond_rounded,
               Icons.star_rounded, Icons.circle, Icons.square_rounded][i],
              size: 16,
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
          );
        }),
        SlideTransition(
          position: _slideAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.25),
                      AppColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset('assets/logo.png', height: 70, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ready to Explore?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  )),
              const SizedBox(height: 8),
              Text('Your cinematic journey begins now',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accent.withValues(alpha: 0.7),
                    fontFamily: 'Poppins',
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _readyIcon(Icons.movie_rounded),
                  const SizedBox(width: 12),
                  _readyIcon(Icons.explore_rounded),
                  const SizedBox(width: 12),
                  _readyIcon(Icons.auto_awesome_rounded),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readyIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1),
      ),
      child: Icon(icon, color: AppColors.accent.withValues(alpha: 0.6), size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BgPatternPainter(_currentPage),
                );
              },
            ),
          ),
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 48,
              right: 16,
              child: TextButton(
                onPressed: _skip,
                child: Text('Skip',
                    style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
              ),
            ),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _slideController.reset();
              _slideController.forward();
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              final isLast = index == _pages.length - 1;
              final isFirst = index == 0;
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        SizedBox(
                          height: 280,
                          child: isLast
                              ? _buildReadyPage()
                              : _buildIconArea(index, page, isFirst),
                        ),
                        const SizedBox(height: 32),
                        if (!isLast) ...[
                          SlideTransition(
                            position: _slideAnim,
                            child: Text(page.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                )),
                          ),
                          const SizedBox(height: 8),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: Text(page.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.accent,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                          const SizedBox(height: 12),
                          if (page.desc.isNotEmpty)
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _slideController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: Text(page.desc,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    height: 1.6,
                                  )),
                            ),
                        ],
                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _currentPage
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.accentSecondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String desc;
  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.desc,
  });
}

class _BgPatternPainter extends CustomPainter {
  final int pageIndex;
  _BgPatternPainter(this.pageIndex);

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = AppColors.bgDark;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Gold accent gradient overlay
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        center: Alignment(
          cos(pageIndex * 1.2) * 0.4,
          sin(pageIndex * 0.8) * 0.4,
        ),
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Curved lines
    final linePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final yBase = size.height * (0.12 + i * 0.24);
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 10) {
        path.lineTo(x, yBase + sin((x / size.width) * pi * 3 + pageIndex + i) * 25);
      }
      canvas.drawPath(path, linePaint);
    }

    // Circle rings
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final cx = size.width * (0.1 + i * 0.16);
      final cy = size.height * (0.3 + sin(i * 2.0 + pageIndex) * 0.12);
      final r = 25 + sin(i * 1.5) * 10;
      circlePaint.color = AppColors.accent.withValues(alpha: 0.03 + (i % 3) * 0.01);
      canvas.drawCircle(Offset(cx, cy), r, circlePaint);
    }

    // Gold dots scattered
    final dotPaint = Paint()..color = AppColors.accent.withValues(alpha: 0.06);
    for (int i = 0; i < 25; i++) {
      final x = (i * 127.5 + pageIndex * 45) % size.width;
      final y = (i * 89.3 + pageIndex * 25) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3).toDouble(), dotPaint);
    }

    // Corner gold arc accents
    final arcPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final arcSize = 50.0;
    canvas.drawArc(Rect.fromLTWH(12, 12, arcSize, arcSize), 0, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(size.width - 12 - arcSize, 12, arcSize, arcSize), pi / 2, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(12, size.height - 12 - arcSize, arcSize, arcSize), -pi / 2, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(size.width - 12 - arcSize, size.height - 12 - arcSize, arcSize, arcSize), pi, pi / 2, false, arcPaint);
  }

  @override
  bool shouldRepaint(_BgPatternPainter old) => old.pageIndex != pageIndex;
}
