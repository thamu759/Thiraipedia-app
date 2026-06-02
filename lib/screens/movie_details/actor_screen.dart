import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../theme/app_theme.dart';

class ActorScreen extends StatelessWidget {
  const ActorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member =
        ModalRoute.of(context)?.settings.arguments as CastMember?;
    if (member == null) {
      return const Scaffold(
        body: Center(child: Text('No actor data')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage:
                  CachedNetworkImageProvider(member.avatarUrl),
              onBackgroundImageError: (_, _) {},
              child: const Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 20),
            Text(member.name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(member.role,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
