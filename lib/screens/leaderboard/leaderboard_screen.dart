import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    i == 0 ? AppTheme.goldColor : AppTheme.surfaceColor,
                child: Text('#${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text('Critic ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('120 reviews'),
              trailing: Text('${100 - i * 8} pts',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}
