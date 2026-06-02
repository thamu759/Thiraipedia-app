import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/movie.dart';
import '../../../theme/app_colors.dart';

class CastSection extends StatelessWidget {
  final List<CastMember> cast;
  const CastSection({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final member = cast[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: member.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(member.avatarUrl)
                      : null,
                  backgroundColor: AppColors.border,
                  child: member.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white24)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(member.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(member.role,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}
