import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/list_model.dart';

class ListDetailScreen extends StatelessWidget {
  const ListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = ModalRoute.of(context)?.settings.arguments as MovieList?;
    if (list == null) {
      return const Scaffold(
        body: Center(child: Text('List not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Text('${list.movieIds.length} movies',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: list.movieIds.isEmpty
                  ? const Center(
                      child: Text('No movies in this list',
                          style:
                              TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      itemCount: list.movieIds.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text('Movie ${list.movieIds[i]}'),
                          leading: const Icon(Icons.movie,
                              color: AppTheme.primaryColor),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
