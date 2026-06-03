import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/watchlist_provider.dart';
import '../../models/movie.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/skeleton_loading.dart';
import '../movie_details/movie_details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Movie>? _watchlistMovies;
  bool _loading = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadWatchlistMovies();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadWatchlistMovies() async {
    final wl = context.read<WatchlistProvider>();
    if (wl.isEmpty) return;
    setState(() => _loading = true);
    try {
      _watchlistMovies = await _api.getMoviesByIds(wl.movieIds);
    } catch (_) {
      _watchlistMovies = [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Watchlist')),
      body: Consumer<WatchlistProvider>(
        builder: (context, wl, _) {
          if (wl.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64, color: AppTheme.textMuted),
                  SizedBox(height: 16),
                  Text('Your watchlist is empty',
                      style: TextStyle(color: AppTheme.textMuted)),
                  SizedBox(height: 8),
                  Text('Add movies to keep track',
                      style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            );
          }
          if (_loading) {
            return const SkeletonLoading(child: ListSkeleton());
          }
          final movies = _watchlistMovies ?? [];
          return RefreshIndicator(
            onRefresh: _loadWatchlistMovies,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              itemBuilder: (context, i) {
                final movie = movies[i];
                return Dismissible(
                  key: Key(movie.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => wl.toggleMovie(movie.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppTheme.primaryColor,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MovieDetailsScreen(
                                movieId: movie.id))),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          width: 50, height: 70, fit: BoxFit.cover),
                    ),
                    title: Text(movie.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle:
                        Text(movie.genre,
                            style: const TextStyle(
                                color: AppTheme.textMuted)),
                    trailing: Text(movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
