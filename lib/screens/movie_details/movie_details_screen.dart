import 'dart:async';
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/skeleton_loading.dart';
import 'widgets/cast_section.dart';
import 'widgets/review_card.dart';
import '../home/widgets/movie_section.dart';
import '../../theme/app_colors.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  static int _trailerId = 0;
  Timer? _adTimer;
  bool _showFullDescription = false;
  bool _isWriteReviewOpen = false;
  int _reviewRating = 8;
  final _reviewTextController = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host == 'youtu.be') {
      final id = uri.pathSegments.firstOrNull;
      if (id != null && id.length > 5 && id.length < 20) return id;
    }
    final id = uri.queryParameters['v'];
    if (id != null && id.length > 5 && id.length < 20) return id;
    return '';
  }

  static const _adVideoUrl = 'https://player.vimeo.com/video/1197439817?autoplay=1&muted=0&controls=0&title=0&byline=0&portrait=0&badge=0&dnt=1&transparent=1';

  void _playTrailer(String url) {
    if (url.isEmpty) return;
    final videoId = _extractVideoId(url);
    if (videoId.isEmpty) {
      html.window.open(url, '_blank');
      return;
    }
    _trailerId++;
    final containerId = 'trailer-popup-$_trailerId';
    final existing = html.document.getElementById(containerId);
    if (existing != null) return;

    final embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=0&rel=0&modestbranding=1';

    void showTrailer() {
      final c = html.document.getElementById(containerId);
      if (c == null) return;
      c.innerHtml = '';
      final wrapper = html.DivElement()
        ..style.position = 'relative'
        ..style.width = '90%'
        ..style.maxWidth = '800px'
        ..style.aspectRatio = '16/9';
      final closeBtn = html.DivElement()
        ..style.position = 'absolute'
        ..style.top = '12px'
        ..style.right = '12px'
        ..style.zIndex = '10000'
        ..style.width = '40px'
        ..style.height = '40px'
        ..style.background = 'rgba(0,0,0,0.7)'
        ..style.borderRadius = '50%'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.cursor = 'pointer'
        ..style.border = '2px solid rgba(255,255,255,0.25)'
        ..style.boxShadow = '0 2px 12px rgba(0,0,0,0.5)'
        ..innerHtml = '<span style="color:white;font-size:20px;font-weight:800;font-family:Arial,sans-serif">X</span>'
        ..onClick.listen((_) => c.remove());
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.borderRadius = '12px'
        ..allow = 'autoplay; encrypted-media; fullscreen'
        ..allowFullscreen = true;
      wrapper.append(closeBtn);
      wrapper.append(iframe);
      c.append(wrapper);
    }

    final container = html.DivElement()
      ..id = containerId
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.zIndex = '9999'
      ..style.background = 'rgba(0,0,0,0.85)'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center';
    html.document.body?.append(container);

    // Show ad first
    final adWrapper = html.DivElement()
      ..style.position = 'relative'
      ..style.width = '90%'
      ..style.maxWidth = '800px'
      ..style.aspectRatio = '16/9'
      ..style.overflow = 'hidden';
    final closeBtn = html.DivElement()
      ..style.position = 'absolute'
      ..style.top = '12px'
      ..style.right = '12px'
      ..style.zIndex = '10000'
      ..style.width = '40px'
      ..style.height = '40px'
      ..style.background = 'rgba(0,0,0,0.7)'
      ..style.borderRadius = '50%'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.cursor = 'pointer'
      ..style.border = '2px solid rgba(255,255,255,0.25)'
      ..style.boxShadow = '0 2px 12px rgba(0,0,0,0.5)'
      ..innerHtml = '<span style="color:white;font-size:20px;font-weight:800;font-family:Arial,sans-serif">X</span>'
      ..onClick.listen((_) {
        _adTimer?.cancel();
        container.remove();
      });

    // Skeleton loading
    final skeleton = html.DivElement()
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.background = '#1a1a2e'
      ..style.borderRadius = '12px'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.zIndex = '9998'
      ..style.setProperty('flex-direction', 'column')
      ..style.setProperty('gap', '16px')
      ..innerHtml = '''
        <style>
          @keyframes shimmer {
            0% { opacity: 0.3; }
            50% { opacity: 0.8; }
            100% { opacity: 0.3; }
          }
        </style>
        <div style="width:60px;height:60px;border-radius:16px;background:#2a2a4e;animation:shimmer 1.5s ease-in-out infinite;"></div>
        <div style="width:120px;height:12px;border-radius:6px;background:#2a2a4e;animation:shimmer 1.5s ease-in-out infinite;"></div>
      ''';

    final adIframe = html.IFrameElement()
      ..src = _adVideoUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.borderRadius = '12px'
      ..allow = 'autoplay; encrypted-media; fullscreen'
      ..allowFullscreen = true
      ..style.pointerEvents = 'none'
      ..style.display = 'none';
    final skipBtn = html.DivElement()
      ..style.position = 'absolute'
      ..style.bottom = '24px'
      ..style.right = '24px'
      ..style.zIndex = '10001'
      ..style.background = '#FBBF24'
      ..style.color = 'black'
      ..style.padding = '10px 20px 10px 18px'
      ..style.borderRadius = '8px'
      ..style.fontFamily = 'Poppins, sans-serif'
      ..style.fontSize = '14px'
      ..style.fontWeight = '700'
      ..style.cursor = 'pointer'
      ..style.display = 'none'
      ..style.alignItems = 'center'
      ..style.setProperty('gap', '6px')
      ..style.boxShadow = '0 4px 16px rgba(0,0,0,0.3)'
      ..style.transition = 'opacity 0.2s ease'
      ..innerHtml = '''
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <polygon points="5,3 19,12 5,21" fill="black"/>
          <rect x="19" y="4" width="2" height="16" rx="1" fill="black" opacity="0.6"/>
        </svg>
        <span>Skip</span>
      '''
      ..onClick.listen((_) {
        _adTimer?.cancel();
        showTrailer();
      });
    adIframe.onLoad.listen((_) {
      adIframe.style.display = '';
      adIframe.style.pointerEvents = '';
      skeleton.remove();
      skipBtn.style.display = 'flex';
      _adTimer?.cancel();
      _adTimer = Timer(const Duration(seconds: 6), showTrailer);
    });

    adWrapper.append(skeleton);
    adWrapper.append(adIframe);
    adWrapper.append(skipBtn);
    adWrapper.append(closeBtn);
    container.append(adWrapper);
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovieById(widget.movieId);
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _reviewTextController.dispose();
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final movie = provider.selectedMovie;
    final auth = context.watch<AuthProvider>();
    final watchlist = context.watch<WatchlistProvider>();

    if (movie == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const SkeletonLoading(child: MovieDetailsSkeleton()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(movie),
            FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildMovieCard(movie),
                    const SizedBox(height: 20),
                    _buildActionButtons(movie, auth, watchlist),
                    const SizedBox(height: 24),
                    _buildSynopsis(movie),
                    const SizedBox(height: 24),
                    if (movie.cast.isNotEmpty) ...[
                      _buildCastSection(movie),
                      const SizedBox(height: 24),
                    ],
                    _buildReviewsSection(movie, auth, provider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (provider.similarMovies.isNotEmpty)
              MovieSection(
                title: 'Similar Movies',
                movies: provider.similarMovies,
                onMovieTap: (id) {
                  setState(() {});
                  context.read<MovieProvider>().loadMovieById(id);
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Movie movie) {
    return GestureDetector(
      onTap: () => _playTrailer(movie.trailerUrl),
      child: SizedBox(
        height: 310,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.backdropUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.bgDark),
                errorWidget: (_, _, _) => Container(color: AppColors.bgDark),
              )
            else
              Container(color: AppColors.bgDark),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                    Color(0xFF0B0C10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
            Center(
              child: _PulsingPlayButton(onTap: () => _playTrailer(movie.trailerUrl)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'poster_${movie.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: movie.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: AppColors.bgDark),
                        )
                      : Container(
                          color: AppColors.bgDark,
                          child: Center(
                            child: Text(
                              movie.title.isNotEmpty ? movie.title[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white24, fontSize: 32, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                      const SizedBox(width: 4),
                      Text('${movie.rating}',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _infoChip(movie.genre),
                      _infoChip('${movie.releaseYear}'),
                      _infoChip(movie.runtime),
                    ],
                  ),
                  if (movie.director.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(movie.director,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _scoreCircle('Critic', movie.criticScore, AppColors.accent),
                      const SizedBox(width: 24),
                      _scoreCircle('Audience', movie.audienceScore.toDouble(), Colors.white70),
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

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Text(text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _scoreCircle(String label, double score, Color color) {
    final normalized = score > 10 ? score : score * 10;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44, height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44, height: 44,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score > 10 ? score / 100 : score / 10),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) => CircularProgressIndicator(
                    value: val.clamp(0.0, 1.0),
                    strokeWidth: 3.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Text('${normalized.toInt()}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  Widget _buildActionButtons(Movie movie, AuthProvider auth, WatchlistProvider watchlist) {
    final inWatchlist = watchlist.isInWatchlist(movie.id);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - val)),
        child: Opacity(opacity: val, child: child),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => watchlist.toggleWatchlist(movie.id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: inWatchlist ? AppColors.accent.withValues(alpha: 0.15) : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: inWatchlist ? AppColors.accent : AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(inWatchlist ? Icons.bookmark : Icons.bookmark_border, size: 18, color: inWatchlist ? AppColors.accent : AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(inWatchlist ? 'Saved' : 'Watchlist',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: inWatchlist ? AppColors.accent : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!auth.isLoggedIn) {
                  Navigator.pushNamed(context, '/auth');
                  return;
                }
                setState(() => _isWriteReviewOpen = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 18, color: Colors.black),
                          SizedBox(width: 6),
                    Text('Write Review',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsis(Movie movie) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - val)),
        child: Opacity(opacity: val, child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Synopsis',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDDDDDD),
              )),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showFullDescription || movie.description.length <= 200
                      ? movie.description
                      : '${movie.description.substring(0, 200)}...',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.7, fontFamily: 'Poppins'),
                ),
                if (movie.description.length > 200)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _showFullDescription = !_showFullDescription),
                      child: Row(
                        children: [
                          Text(_showFullDescription ? 'Show Less' : 'Read More',
                              style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _showFullDescription ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.expand_more, color: AppColors.accent, size: 18),
                          ),
                        ],
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

  Widget _buildCastSection(Movie movie) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - val)),
        child: Opacity(opacity: val, child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cast & Crew',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDDDDDD),
              )),
          const SizedBox(height: 12),
          CastSection(cast: movie.cast),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Movie movie, AuthProvider auth, MovieProvider provider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - val)),
        child: Opacity(opacity: val, child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews (${movie.reviews.length})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDDDDDD),
              )),
          const SizedBox(height: 12),
          if (movie.reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.rate_review_outlined, color: AppColors.textMuted, size: 32),
                  SizedBox(height: 8),
                  Text('No reviews yet. Be the first!',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Poppins')),
                ],
              ),
            )
          else
            Column(
              children: movie.reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ReviewCard(
                  review: r,
                  movieId: movie.id,
                  currentUser: auth.currentUser,
                  onLike: () {
                    if (!auth.isLoggedIn) {
                      Navigator.pushNamed(context, '/auth');
                      return;
                    }
                    provider.toggleLike(movie.id, r.id, token: auth.token);
                  },
                ),
              )).toList(),
            ),
          _buildWriteReviewModal(movie, auth, provider),
        ],
      ),
    );
  }

  Widget _buildWriteReviewModal(Movie movie, AuthProvider auth, MovieProvider provider) {
    if (!_isWriteReviewOpen) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, val, child) => Transform.scale(scale: val, child: child),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Write Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                GestureDetector(
                  onTap: () => setState(() => _isWriteReviewOpen = false),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: Colors.white54, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Rating', style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontFamily: 'Poppins')),
                const Spacer(),
                ...List.generate(10, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _reviewRating = star),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      padding: const EdgeInsets.all(2),
                      transform: Matrix4.diagonal3Values(star <= _reviewRating ? 1.1 : 1.0, star <= _reviewRating ? 1.1 : 1.0, 1.0),
                      child: Icon(
                        star <= _reviewRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewTextController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
                contentPadding: const EdgeInsets.all(14),
                filled: true,
                fillColor: AppColors.bgDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  if (_reviewTextController.text.trim().isEmpty) return;
                  if (!auth.isLoggedIn) {
                    Navigator.pushNamed(context, '/auth');
                    return;
                  }
                  try {
                    await provider.addReview(movie.id,
                      rating: _reviewRating.toDouble(),
                      text: _reviewTextController.text.trim(),
                      token: auth.token,
                    );
                    if (!mounted) return;
                    setState(() {
                      _isWriteReviewOpen = false;
                      _reviewTextController.clear();
                      _reviewRating = 8;
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Submit Review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingPlayButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PulsingPlayButton({required this.onTap});

  @override
  State<_PulsingPlayButton> createState() => _PulsingPlayButtonState();
}

class _PulsingPlayButtonState extends State<_PulsingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) => Transform.scale(
          scale: _pulse.value,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 38),
          ),
        ),
      ),
    );
  }
}
