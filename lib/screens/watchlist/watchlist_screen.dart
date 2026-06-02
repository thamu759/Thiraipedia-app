import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/movie_provider.dart';
import '../../models/movie.dart';
import '../../theme/app_theme.dart';
import '../movie_details/movie_details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Movie>? _watchlistMovies;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWatchlistMovies();
  }

  Future<void> _loadWatchlistMovies() async {
    final wl = context.read<WatchlistProvider>();
    if (wl.isEmpty) return;
    setState(() => _loading = true);
    final mp = context.read<MovieProvider>();
    await mp.fetchMovies();
    final allMovies = mp.movies;
    setState(() {
      _watchlistMovies =
          allMovies.where((m) => wl.movieIds.contains(m.id)).toList();
      _loading = false;
    });
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
                      style: TextStyle(color: AppTheme.textSecondary)),
                  SizedBox(height: 8),
                  Text('Add movies to keep track',
                      style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            );
          }
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
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
                      child: Image.network(movie.posterUrl,
                          width: 50, height: 70, fit: BoxFit.cover),
                    ),
                    title: Text(movie.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle:
                        Text(movie.genre,
                            style: const TextStyle(
                                color: AppTheme.textSecondary)),
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
