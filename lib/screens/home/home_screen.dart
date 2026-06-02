import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../theme/app_theme.dart';
import '../movie_details/movie_details_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchMovies();
      context.read<AuthProvider>().loadUser();
      context.read<WatchlistProvider>().loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [_buildHomeTab(), _buildExploreTab(), _buildProfileTab()];

    return Scaffold(
      body: screens[_currentNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<MovieProvider>().fetchMovies(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildHeroCarousel(),
              _buildSectionTitle('Staff Picks'),
              _buildStaffPicks(),
              _buildSectionTitle('Trending Now'),
              _buildMovieGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildExploreGrid(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline,
                      size: 80, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text('Sign in to see your profile',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/auth'),
                      child: const Text('Sign In')),
                ],
              ),
            );
          }
          return const ProfileScreen();
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('thiraipedia',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  )),
              const Text('Film Critique & Reviews',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.pushNamed(context, '/search')),
          Consumer<WatchlistProvider>(
            builder: (_, wl, __) => Stack(
              children: [
                IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/watchlist')),
                if (wl.count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle),
                      child: Text('${wl.count}',
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Consumer<MovieProvider>(
      builder: (context, mp, _) {
        if (mp.loading && mp.heroMovies.isEmpty) {
          return Shimmer.fromColors(
            baseColor: AppTheme.surfaceColor,
            highlightColor: AppTheme.borderColor,
            child: Container(
              height: 420,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.cardColor),
            ),
          );
        }
        final heroes = mp.heroMovies;
        if (heroes.isEmpty) return const SizedBox.shrink();
        return CarouselSlider(
          options: CarouselOptions(
            height: 420,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 0.9,
            enlargeCenterPage: true,
          ),
          items: heroes.map((movie) => _buildHeroCard(movie)).toList(),
        );
      },
    );
  }

  Widget _buildHeroCard(movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(movieId: movie.id))),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: CachedNetworkImageProvider(movie.backdropUrl),
                fit: BoxFit.cover,
                onError: (_, __) =>
                    const AssetImage('assets/placeholder.jpg'),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildRatingBadge(movie.rating),
                    const SizedBox(width: 8),
                    Text(movie.genre,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.getRatingGradient(rating)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(rating.toStringAsFixed(1),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaffPicks() {
    return Consumer<MovieProvider>(
      builder: (context, mp, _) {
        final picks =
            mp.staffPicks.take(8).toList();
        if (picks.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: picks.length,
            itemBuilder: (context, i) {
              final movie = picks[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            MovieDetailsScreen(movieId: movie.id))),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(movie.posterUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) =>
                          const AssetImage('assets/placeholder.jpg'),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMovieGrid() {
    return Consumer<MovieProvider>(
      builder: (context, mp, _) {
        if (mp.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final movies = mp.movies;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: movies.length,
          itemBuilder: (context, i) {
            final movie = movies[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          MovieDetailsScreen(movieId: movie.id))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppTheme.surfaceColor,
                          highlightColor: AppTheme.borderColor,
                          child: Container(color: AppTheme.cardColor),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.cardColor,
                          child: const Icon(Icons.movie,
                              color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(movie.title,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExploreGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
        children: [
          _exploreItem(Icons.movie, 'Movies', '/search'),
          _exploreItem(Icons.people, 'Community', '/community'),
          _exploreItem(Icons.leaderboard, 'Leaderboard', '/leaderboard'),
          _exploreItem(Icons.list, 'Lists', '/lists'),
          _exploreItem(Icons.calendar_today, 'OTT Calendar', '/ott-calendar'),
          _exploreItem(Icons.article, 'Articles', '/articles'),
          _exploreItem(Icons.quiz, 'Quiz', '/quiz'),
          _exploreItem(Icons.games, 'Games', '/wheel'),
          _exploreItem(Icons.upcoming, 'Coming Soon', '/coming-soon'),
        ],
      ),
    );
  }

  Widget _exploreItem(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
