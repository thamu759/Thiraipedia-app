import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_theme.dart';
import '../movie_details/movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      context.read<MovieProvider>().searchMovies('');
                    })
                : null,
          ),
          onChanged: (query) {
            setState(() {});
            context.read<MovieProvider>().searchMovies(query);
          },
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, mp, _) {
          if (mp.searching) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.text.isEmpty) {
            return const Center(
              child: Text('Start typing to search',
                  style: TextStyle(color: AppTheme.textMuted)),
            );
          }
          if (mp.searchResults.isEmpty) {
            return const Center(
              child: Text('No movies found',
                  style: TextStyle(color: AppTheme.textMuted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mp.searchResults.length,
            itemBuilder: (context, i) {
              final movie = mp.searchResults[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            MovieDetailsScreen(movieId: movie.id))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(Icons.movie),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(movie.genre,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppTheme
                                        .getRatingGradient(movie.rating)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                      movie.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Text(movie.releaseYear.toString(),
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
