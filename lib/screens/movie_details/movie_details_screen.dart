import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../theme/app_theme.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchMovieById(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, mp, _) {
          if (mp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final movie = mp.selectedMovie;
          if (movie == null) {
            return const Center(child: Text('Movie not found'));
          }
          return _buildContent(movie);
        },
      ),
    );
  }

  Widget _buildContent(Movie movie) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(movie),
        SliverToBoxAdapter(child: _buildBody(movie)),
      ],
    );
  }

  Widget _buildSliverAppBar(Movie movie) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.backdropUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.cardColor,
                child: const Icon(Icons.movie, size: 60),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<WatchlistProvider>(
          builder: (context, wl, _) => IconButton(
            icon: Icon(
              wl.isInWatchlist(movie.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: wl.isInWatchlist(movie.id)
                  ? AppTheme.primaryColor
                  : null,
            ),
            onPressed: () => wl.toggleMovie(movie.id),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(Movie movie) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(movie.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _ratingChip(movie.rating, 'Rating'),
              const SizedBox(width: 8),
              _ratingChip(movie.criticScore.toDouble(), 'Critic'),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${movie.audienceScore}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.calendar_today, movie.releaseYear.toString()),
              if (movie.runtime.isNotEmpty) ...[
                const SizedBox(width: 8),
                _infoChip(Icons.access_time, movie.runtime),
              ],
              if (movie.language.isNotEmpty) ...[
                const SizedBox(width: 8),
                _infoChip(Icons.language, movie.language),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: movie.genre.split(' / ').map((g) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.primaryColor.withAlpha(80)),
                ),
                child: Text(g,
                    style: const TextStyle(
                        color: AppTheme.primaryColor, fontSize: 12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Synopsis',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(movie.description,
              style: const TextStyle(
                  color: AppTheme.textSecondary, height: 1.5)),
          if (movie.director.isNotEmpty ||
              movie.writer.isNotEmpty ||
              movie.studio.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Details',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (movie.director.isNotEmpty)
              _detailRow('Director', movie.director),
            if (movie.writer.isNotEmpty)
              _detailRow('Writer', movie.writer),
            if (movie.studio.isNotEmpty)
              _detailRow('Studio', movie.studio),
          ],
          if (movie.cast.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Cast',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movie.cast.length,
                itemBuilder: (context, i) {
                  final member = movie.cast[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/actor',
                        arguments: member),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage:
                                CachedNetworkImageProvider(
                                    member.avatarUrl),
                            onBackgroundImageError: (_, __) {},
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 6),
                          Text(member.name,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center),
                          Text(member.role,
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Reviews',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (movie.reviews.isEmpty)
            const Text('No reviews yet. Be the first to review!',
                style: TextStyle(color: AppTheme.textMuted))
          else
            ...movie.reviews.map((r) => _reviewCard(movie, r)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _ratingChip(double rating, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: AppTheme.getRatingGradient(rating)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Movie movie, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    CachedNetworkImageProvider(review.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.user,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(review.role,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              _ratingChip(review.rating.toDouble(), ''),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.text,
              style: const TextStyle(
                  color: AppTheme.textSecondary, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(review.timestamp,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.favorite_border, size: 18),
                onPressed: () => _toggleLike(movie.id, review.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Text('${review.likes}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          if (review.replies.isNotEmpty) ...[
            const Divider(),
            ...review.replies.take(2).map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${reply.author}: ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      Expanded(
                        child: Text(reply.body,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  void _toggleLike(String movieId, String reviewId) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/auth');
      return;
    }
    context
        .read<MovieProvider>()
        .toggleLike(movieId, reviewId, token: auth.token);
  }
}
