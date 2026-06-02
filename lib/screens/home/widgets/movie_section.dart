import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/movie.dart';
import '../../../theme/app_colors.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final String? languageLabel;
  final List<Movie> movies;
  final void Function(String movieId) onMovieTap;
  final VoidCallback? onSeeAll;

  const MovieSection({
    super.key,
    required this.title,
    this.languageLabel,
    required this.movies,
    required this.onMovieTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (languageLabel != null)
                    Text(languageLabel!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          letterSpacing: 1.5,
                        )),
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDDDDDD),
                      )),
                ],
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                child: Row(
                  children: [
                    Text('See All',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.accent),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length > 15 ? 15 : movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => onMovieTap(movie.id),
                child: Container(
                  width: 185,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                    color: AppColors.bgCard,
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
                                    child: const Icon(Icons.movie, color: Colors.white24),
                                  ),
                            if (movie.rating > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: AppColors.border),
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
                        padding: const EdgeInsets.all(8),
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
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.language, color: AppColors.textMuted, size: 10),
                                const SizedBox(width: 2),
                                Text(movie.displayLanguage,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', color: AppColors.textMuted, fontSize: 11)),
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
          ),
        ),
      ],
    );
  }
}
