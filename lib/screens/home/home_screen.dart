import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../theme/app_colors.dart';

import '../../widgets/skeleton_loading.dart';
import '../movie_details/movie_details_screen.dart';
import '../see_all/see_all_screen.dart';
import '../games/quiz_screen.dart';
import '../games/card_flix_screen.dart';
import '../games/blind_frame_screen.dart';
import '../games/mood_matcher_screen.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/movie_section.dart';
import 'widgets/staff_picks_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    context.read<AuthProvider>().verifySession();
    context.read<MovieProvider>().loadMovies();
    context.read<MovieProvider>().loadNewReleases();
  }

  void _navigateTo(String route) {
    final pages = <String, Widget>{
      '/quiz': const QuizScreen(),
      '/card-flix': const CardFlixScreen(),
      '/blind-frame': const BlindFrameScreen(),
      '/mood-matcher': const MoodMatcherScreen(),
    };
    final page = pages[route];
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _navigateToMovie(String movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movieId)),
    );
  }

  void _navigateToSeeAll(String title, List<Movie> movies) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SeeAllScreen(title: title, movies: movies)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MovieProvider>();

    if (mp.isLoading && mp.movies.isEmpty) {
      return const SkeletonLoading(child: HomeSkeleton());
    }
    if (mp.error != null && mp.movies.isEmpty) {
      return _buildError(mp.error!);
    }
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPersistentHeader(
          pinned: false,
          floating: false,
          delegate: _HeaderDelegate(maxHeight: MediaQuery.of(context).padding.top + 100),
        ),
        SliverToBoxAdapter(
          child: _buildContent(mp),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textMuted,
                    fontSize: 13,
                  )),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MovieProvider mp) {
    return Column(
        children: [
          if (mp.heroMovies.isNotEmpty)
            SizedBox(
              height: 440,
              child: HeroCarousel(
                movies: mp.heroMovies,
                onMovieTap: _navigateToMovie,
                onWatchlistToggle: (id) => context.read<WatchlistProvider>().toggleWatchlist(id),
                isInWatchlist: (id) => context.read<WatchlistProvider>().isInWatchlist(id),
              ),
            ),
          const SizedBox(height: 28),
          if (mp.newReleases.isNotEmpty)
            MovieSection(
              title: 'New Release',
              languageLabel: 'TRENDING',
              movies: mp.newReleases,
              onMovieTap: _navigateToMovie,
              onSeeAll: () => _navigateToSeeAll('New Release', mp.newReleases),
            ),
          const SizedBox(height: 28),
          if (mp.tamilMovies.isNotEmpty)
            MovieSection(
              title: 'Tamil Cinema',
              languageLabel: 'தமிழ்',
              movies: mp.tamilMovies,
              onMovieTap: _navigateToMovie,
              onSeeAll: () => _navigateToSeeAll('Tamil Cinema', mp.tamilMovies),
            ),
          const SizedBox(height: 28),
          if (mp.malayalamMovies.isNotEmpty)
            MovieSection(
              title: 'Malayalam Cinema',
              languageLabel: 'മലയാളം',
              movies: mp.malayalamMovies,
              onMovieTap: _navigateToMovie,
              onSeeAll: () => _navigateToSeeAll('Malayalam Cinema', mp.malayalamMovies),
            ),
          const SizedBox(height: 28),
          if (mp.topRatedMovies.isNotEmpty)
            MovieSection(
              title: 'Top Rated',
              languageLabel: 'BEST',
              movies: mp.topRatedMovies,
              onMovieTap: _navigateToMovie,
              onSeeAll: () => _navigateToSeeAll('Top Rated', mp.topRatedMovies),
            ),
          const SizedBox(height: 28),
          if (mp.staffPicks.isNotEmpty)
            StaffPicksSection(
              movies: mp.staffPicks,
              onMovieTap: _navigateToMovie,
            ),
          const SizedBox(height: 28),
          _buildFunActivities(),
          const SizedBox(height: 28),
        ],
      );
    }

  Widget _buildFunActivities() {
    final activities = [
      ('Quiz', Icons.quiz, '/quiz', 'Test your film knowledge', const Color(0xFFE57373)),
      ('Card Flix', Icons.style, '/card-flix', 'Swipe & pick', const Color(0xFF64B5F6)),
      ('Blind Frame', Icons.blur_on, '/blind-frame', 'Guess the movie', const Color(0xFF81C784)),
      ('Mood Matcher', Icons.mood, '/mood-matcher', 'Find by mood', const Color(0xFFBA68C8)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.games_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Fun Activities',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDDDDDD),
                  )),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final act = activities[index];
              return GestureDetector(
                onTap: () => _navigateTo(act.$3),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    color: AppColors.bgCard,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: act.$5.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(act.$2, color: act.$5, size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(act.$1,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(act.$4,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textMuted,
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;

  _HeaderDelegate({required this.maxHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final maxH = maxHeight;
    final minH = minExtent;
    final totalShrink = maxH - minH;
    final shrink = totalShrink > 0 ? ((maxH - shrinkOffset) / maxH).clamp(0.0, 1.0) : 1.0;
    final opacity = shrink;
    final scale = 0.6 + (0.4 * shrink);
    final lineWidth = 48 + ((1.0 - shrink) * 72);
    final lineOpacity = shrink;
    final glowOpacity = 0.2 + (0.8 * shrink);
    final glassOpacity = (1.0 - shrink).clamp(0.0, 0.85);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgDark,
            AppColors.bgDark.withValues(alpha: 0.3 + (0.4 * shrink)),
            Color.fromRGBO(10, 10, 20, (0.2 * shrink).clamp(0.0, 0.2)),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Glass bar on scroll
          Positioned(
            top: 0, left: 0, right: 0,
            child: Opacity(
              opacity: glassOpacity,
              child: Container(
                height: maxH,
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.3),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset('assets/logo.png', height: 28, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: lineOpacity,
                child: Container(
                  width: lineWidth, height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: glowOpacity),
                        blurRadius: 8 + ((1.0 - shrink) * 12),
                        spreadRadius: (1.0 - shrink) * 2,
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

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) => true;

  @override
  double get minExtent => 0;
  @override
  double get maxExtent => maxHeight;
}
