import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/movie.dart';
import '../../../theme/app_colors.dart';

class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;
  final void Function(String movieId) onMovieTap;
  final void Function(String movieId) onWatchlistToggle;

  const HeroCarousel({
    super.key,
    required this.movies,
    required this.onMovieTap,
    required this.onWatchlistToggle,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _pageCtrl;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (widget.movies.length < 2) return;
      final next = (_currentIndex + 1) % widget.movies.length;
      _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  void _goTo(int index) {
    _timer?.cancel();
    _startAutoScroll();
    _pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 440,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.movies.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => _buildSlide(widget.movies[index], index),
          ),
          if (widget.movies.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildIndicators(),
            ),
        ],
      ),
    );
  }

  Widget _buildSlide(Movie movie, int index) {
    final isActive = index == _currentIndex;
    return GestureDetector(
      onTap: () => widget.onMovieTap(movie.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(
          top: isActive ? 0 : 12,
          bottom: isActive ? 0 : 12,
          right: isActive ? 0 : 8,
          left: isActive ? 0 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(isActive ? 1.0 : 0.95, isActive ? 1.0 : 0.95, 1.0),
              child: movie.backdropUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.bgDark),
                      errorWidget: (_, _, _) => Container(color: AppColors.bgDark),
                    )
                  : Container(color: AppColors.bgDark),
            ),
            // Multi-layer gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Side gradients for focus
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            // Rating badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('${movie.rating}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                  ],
                ),
              ),
            ),
            // Content overlay
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  movie.titleLogo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.titleLogo,
                          height: 36,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          placeholder: (_, _) => const SizedBox.shrink(),
                          errorWidget: (_, _, _) => Text(movie.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.1,
                                shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        )
                      : Text(movie.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            height: 1.1,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _metaChip(movie.genre),
                      const SizedBox(width: 8),
                      Text('${movie.releaseYear}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text(movie.displayLanguage,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _actionButton(Icons.play_arrow_rounded, 'View', true, () => widget.onMovieTap(movie.id)),
                      const SizedBox(width: 10),
                      _actionButton(Icons.bookmark_border, 'Watchlist', false, () => widget.onWatchlistToggle(movie.id)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _actionButton(IconData icon, String label, bool filled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppColors.accent : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: filled ? Colors.black : Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: filled ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.movies.length, (i) {
        final isActive = i == _currentIndex;
        return GestureDetector(
          onTap: () => _goTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 28 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
