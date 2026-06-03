import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_colors.dart';
import '../movie_details/movie_details_screen.dart';

class CardFlixScreen extends StatefulWidget {
  const CardFlixScreen({super.key});

  @override
  State<CardFlixScreen> createState() => _CardFlixScreenState();
}

class _CardFlixScreenState extends State<CardFlixScreen>
    with TickerProviderStateMixin {
  late List<Movie> _movies;
  int _currentIndex = 0;
  int _flipped = 0;

  late AnimationController _flipController;
  late Animation<double> _flipAnim;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flipAnim = CurvedAnimation(parent: _flipController, curve: Curves.easeInOut);
    _flipAnim.addListener(() => setState(() {}));
    _flipAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRevealed = true;
          _flipped++;
        });
      }
    });
    _loadMovies();
  }

  void _loadMovies() {
    final mp = context.read<MovieProvider>();
    _movies = List.from(mp.movies)..shuffle();
    _currentIndex = 0;
    _flipped = 0;
    _isRevealed = false;
  }

  void _reset() {
    setState(() {
      _flipController.reset();
      _loadMovies();
    });
  }

  void _flip() {
    if (_flipController.isAnimating || _isRevealed) return;
    _flipController.forward();
  }

  void _nextMovie() {
    setState(() {
      _currentIndex++;
      _isRevealed = false;
      _flipController.reset();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Card Flix',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark,
        automaticallyImplyLeading: true,
      ),
      body: _movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex >= _movies.length
              ? _buildDone()
              : _buildContent(),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('All cards flipped!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text('$_flipped cards flipped',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontFamily: 'Poppins')),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _reset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text('Shuffle Again',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white, fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final movie = _movies[_currentIndex];
    final flipValue = _flipAnim.value;
    final angle = pi * flipValue;

    return Column(
      children: [
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _flip,
              child: SizedBox(
                width: 280,
                height: 400,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: angle < pi / 2
                      ? _buildCardFront()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(pi),
                          child: _buildCardBack(movie),
                        ),
                ),
              ),
            ),
          ),
        ),
        if (!_isRevealed)
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: AppColors.accent, size: 16),
                  SizedBox(width: 6),
                  Text('Tap to flip',
                      style: TextStyle(color: AppColors.accent, fontSize: 13, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
        if (_isRevealed)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const Text('You should watch',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(movie.title,
                    style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('View',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _nextMovie,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Next',
                                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: 280,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1C3A),
            Color(0xFF12122A),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gold pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _GoldPatternPainter(),
              ),
            ),
            // Top-right glow
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 2),
                      color: const Color(0xFFFFD700).withValues(alpha: 0.06),
                    ),
                    child: Center(
                      child: Icon(Icons.auto_awesome_rounded, color: const Color(0xFFFFD700).withValues(alpha: 0.6), size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('MYSTERY CARD',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      )),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFFFD700).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner ornaments
            Positioned(top: 10, left: 10, child: _cornerOrnament()),
            Positioned(top: 10, right: 10, child: _cornerOrnament()),
            Positioned(bottom: 10, left: 10, child: _cornerOrnament()),
            Positioned(bottom: 10, right: 10, child: _cornerOrnament()),
            // Border
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.15), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerOrnament() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2), width: 1),
        color: const Color(0xFFFFD700).withValues(alpha: 0.04),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(Movie movie) {
    return Container(
      width: 280,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.posterUrl.isNotEmpty)
              CachedNetworkImage(imageUrl: movie.posterUrl, fit: BoxFit.cover,
                  errorWidget: (_, a, b) => _fallbackCard(movie))
            else
              _fallbackCard(movie),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.black87, size: 14),
                    const SizedBox(width: 3),
                    Text('${movie.rating}',
                        style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16, right: 16, bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(movie.genre.split('/').first,
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins')),
                  ),
                  const SizedBox(height: 8),
                  Text(movie.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                      )),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(movie.releaseYear.toString(),
                          style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Poppins')),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|', style: TextStyle(color: Colors.white30)),
                      ),
                      Text(movie.displayLanguage,
                          style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Poppins')),
                      if (movie.director.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text('|', style: TextStyle(color: Colors.white30)),
                        ),
                        Flexible(
                          child: Text(movie.director,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Poppins')),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(movie.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Poppins', height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackCard(Movie movie) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgCard, AppColors.bgCard.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

}

class _GoldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = const Color(0xFFFFD700);

    // Diamond grid
    final gridPaint = Paint()
      ..color = gold.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.height / 2);
    for (int r = 1; r < 7; r++) {
      final s = r * 28.0;
      final path = Path()
        ..moveTo(center.dx, center.dy - s)
        ..lineTo(center.dx + s, center.dy)
        ..lineTo(center.dx, center.dy + s)
        ..lineTo(center.dx - s, center.dy)
        ..close();
      canvas.drawPath(path, gridPaint);
    }

    // Horizontal lines
    final linePaint = Paint()
      ..color = gold.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Corner arc accents
    final arcPaint = Paint()
      ..color = gold.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(Rect.fromLTWH(8, 8, 40, 40), 0, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(size.width - 48, 8, 40, 40), pi / 2, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(8, size.height - 48, 40, 40), -pi / 2, pi / 2, false, arcPaint);
    canvas.drawArc(Rect.fromLTWH(size.width - 48, size.height - 48, 40, 40), pi, pi / 2, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
