import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../theme/app_colors.dart';
import '../../widgets/skeleton_loading.dart';
import '../movie_details/movie_details_screen.dart';

class SeeAllScreen extends StatefulWidget {
  final String title;
  final List<Movie> movies;

  const SeeAllScreen({super.key, required this.title, required this.movies});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen>
    with SingleTickerProviderStateMixin {
  late int _displayCount;
  bool _ready = false;
  late AnimationController _shimmerCtrl;
  static const _pageSize = 15;
  static const _loadMoreCount = 10;

  @override
  void initState() {
    super.initState();
    _displayCount = _pageSize;
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _ready = true);
      _shimmerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  bool get _hasMore => _displayCount < widget.movies.length;

  @override
  Widget build(BuildContext context) {
    final displayMovies = widget.movies.take(_displayCount).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: _ready
          ? CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  toolbarHeight: 0,
                  expandedHeight: 130,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: _buildHeader(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMovieCard(displayMovies[index], index),
                      childCount: displayMovies.length,
                    ),
                  ),
                ),
                if (_hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32, top: 4),
                      child: _buildLoadMore(),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            )
          : const SkeletonLoading(child: _SeeAllSkeleton()),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shrink = (constraints.maxHeight / 130).clamp(0.0, 1.0);
        final opacity = shrink;
        final titleScale = 0.7 + (0.3 * shrink);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgDark,
                AppColors.bgDark.withValues(alpha: 0.6 + (0.3 * shrink)),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Glass bar at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.top + 56,
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.4 * (1 - shrink)),
                  ),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: titleScale,
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                )),
                            const SizedBox(height: 10),
                            Container(
                              width: 36, height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 500 + (index % _pageSize) * 25),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) => Transform.translate(
          offset: Offset(0, 50 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            color: AppColors.bgCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    movie.posterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: AppColors.bgDark),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.bgDark,
                              child: const Icon(Icons.movie, color: Colors.white24),
                            ),
                          )
                        : Container(
                            color: AppColors.bgDark,
                            child: const Center(child: Icon(Icons.movie, color: Colors.white24)),
                          ),
                    if (movie.rating > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: AppColors.accent, size: 10),
                              const SizedBox(width: 2),
                              Text('${movie.rating}',
                                  style: const TextStyle(
                                      color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textMain,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.language, color: AppColors.textMuted, size: 10),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(movie.displayLanguage,
                              style: const TextStyle(
                                  fontFamily: 'Poppins', color: AppColors.textMuted, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const Spacer(),
                        Text('${movie.releaseYear}',
                            style: const TextStyle(
                                fontFamily: 'Poppins', color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Opacity(opacity: val, child: child),
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => _displayCount += _loadMoreCount),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.2),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Load More (${widget.movies.length - _displayCount})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.expand_more, color: AppColors.accent, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeeAllSkeleton extends StatelessWidget {
  const _SeeAllSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 130,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                    ],
                  ),
                ),
                const Spacer(),
                const Column(
                  children: [
                    ShimmerPlaceholder(width: 140, height: 22, borderRadius: 4),
                    SizedBox(height: 10),
                    ShimmerPlaceholder(width: 36, height: 3, borderRadius: 2),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.bgCard,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerPlaceholder(width: double.infinity, height: 13, borderRadius: 3),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ShimmerPlaceholder(width: 60, height: 11, borderRadius: 3),
                              Spacer(),
                              ShimmerPlaceholder(width: 30, height: 11, borderRadius: 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
