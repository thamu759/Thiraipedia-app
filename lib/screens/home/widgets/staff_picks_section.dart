import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/movie.dart';
import '../../../theme/app_colors.dart';

class StaffPicksSection extends StatelessWidget {
  final List<Movie> movies;
  final void Function(String movieId) onMovieTap;

  const StaffPicksSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    final featured = movies.where((m) => m.staffPickType == 'featured').firstOrNull;
    final gridMovies = movies.where((m) => m.staffPickType != 'featured').take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
          child: Row(
            children: [
              const Text('★ CURATED',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(width: 10),
              Text('Staff Picks',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDDDDDD),
                  )),
            ],
          ),
        ),
        if (featured != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FeaturedCard(movie: featured, onTap: () => onMovieTap(featured.id)),
          ),
        if (gridMovies.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...gridMovies.map((m) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
            child: _GridCard(movie: m, onTap: () => onMovieTap(m.id)),
          )),
        ],
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _FeaturedCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 290,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            movie.backdropUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: AppColors.bgDark),
                    errorWidget: (_, _, _) => Container(color: AppColors.bgDark),
                  )
                : Container(color: AppColors.bgDark),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  const Text('HOME DISCOVERY',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      )),
                  const SizedBox(height: 6),
                  Text(movie.description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _GridCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.bgCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 90,
          child: Row(
          children: [
            SizedBox(
              width: 80,
              child: movie.backdropUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.backdropUrl,
                      height: double.infinity,
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
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(movie.genre,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const                     SizedBox(height: 4),
                    Text(movie.title,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}