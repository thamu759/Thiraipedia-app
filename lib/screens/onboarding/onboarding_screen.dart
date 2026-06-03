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

  final _pages = const [
    _PageData(
      icon: Icons.movie_creation_rounded,
      iconBg: Color(0xFFE57373),
      title: 'Thiraipedia',
      subtitle: 'Your complete guide to Tamil cinema',
      desc: 'Discover movies, read reviews, watch trailers, and stay updated with the latest releases — all in one place.',
    ),
    _PageData(
      icon: Icons.explore_rounded,
      iconBg: Color(0xFF64B5F6),
      title: 'Browse & Explore',
      subtitle: '200+ movies at your fingertips',
      desc: 'Filter by genre, language, rating, or OTT platform. Find staff picks, top rated, and hidden gems you will love.',
    ),
    _PageData(
      icon: Icons.auto_awesome_rounded,
      iconBg: Color(0xFFBA68C8),
      title: 'Fun Activities',
      subtitle: 'Quiz, Card Flix, Blind Frame & more',
      desc: 'Test your movie knowledge, swipe through mystery cards, guess films from blurred posters, or find one by your mood.',
    ),
    _PageData(
      icon: Icons.rocket_launch_rounded,
      iconBg: Color(0xFF4DB6AC),
      title: 'Ready?',
      subtitle: 'Start your movie journey now',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Pattern background
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
          // Skip
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
          // Main content
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
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        // Decorative art area
                        SizedBox(
                          height: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Floating decorations
                              ...List.generate(6, (i) {
                                final a = (i * pi / 3) + (index * 0.2);
                                final dist = 90.0 + sin(index * 0.5 + i) * 20;
                                return Positioned(
                                  left: 140 + cos(a) * dist - 8,
                                  top: 140 + sin(a) * dist - 8,
                                  child: Opacity(
                                    opacity: 0.15 + (sin(i * 2.3 + index) * 0.08).abs(),
                                    child: Icon(
                                      [Icons.star_rounded, Icons.circle, Icons.square_rounded,
                                       Icons.diamond_rounded, Icons.star_rounded, Icons.circle][i],
                                      size: 14 + (i % 3) * 6,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              }),
                              // Main icon circle
                              SlideTransition(
                                position: _slideAnim,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        page.iconBg.withValues(alpha: 0.3),
                                        page.iconBg.withValues(alpha: 0.08),
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
                                        color: page.iconBg.withValues(alpha: 0.15),
                                        border: Border.all(
                                          color: page.iconBg.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(page.icon, color: page.iconBg, size: 44),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
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
                        // Subtitle
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
                              style: TextStyle(
                                fontSize: 14,
                                color: page.iconBg.withValues(alpha: 0.8),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        const SizedBox(height: 12),
                        // Description
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
                        if (isLast) ...[
                          const SizedBox(height: 24),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withValues(alpha: 0.1),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 2),
                              ),
                              child: const Icon(Icons.rocket_launch_rounded, color: AppColors.accent, size: 36),
                            ),
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
          // Bottom bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dots
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
                            ? _pages[i].iconBg
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Button
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _pages[_currentPage].iconBg,
                          _pages[_currentPage].iconBg.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].iconBg.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
  final Color iconBg;
  final String title;
  final String subtitle;
  final String desc;
  const _PageData({
    required this.icon,
    required this.iconBg,
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
    final colors = [
      const Color(0xFF1A1A3E),
      const Color(0xFF0D2B3E),
      const Color(0xFF2D1B3E),
      const Color(0xFF0D3E2E),
    ];
    final accent = colors[pageIndex % colors.length];

    // Diagonal gradient bg
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.bgDark,
          accent.withValues(alpha: 0.3),
          AppColors.bgDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Curved decorative lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final yBase = size.height * (0.15 + i * 0.22);
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 10) {
        path.lineTo(x, yBase + sin((x / size.width) * pi * 3 + pageIndex + i) * 30);
      }
      canvas.drawPath(path, linePaint);
    }

    // Circle patterns
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final cx = size.width * (0.1 + i * 0.12);
      final cy = size.height * (0.2 + sin(i * 2.3 + pageIndex) * 0.15);
      final r = 20 + sin(i * 1.7) * 10;
      circlePaint.color = Colors.white.withValues(alpha: 0.02 + (i % 3) * 0.01);
      canvas.drawCircle(Offset(cx, cy), r, circlePaint);
    }

    // Starburst dots
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (int i = 0; i < 20; i++) {
      final x = (i * 137.5 + pageIndex * 50) % size.width;
      final y = (i * 97.3 + pageIndex * 30) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3).toDouble(), dotPaint);
    }
  }

  @override
  bool shouldRepaint(_BgPatternPainter old) => old.pageIndex != pageIndex;
}
