import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/games/reels_screen.dart';
import '../screens/watchlist/watchlist_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int activeIndex;
  final void Function(int index)? onTap;

  const AppBottomNav({super.key, required this.activeIndex, this.onTap});

  void _navigateToReels(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReelsScreen()),
    );
  }

  void _navigateToWatchlist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WatchlistScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_filled, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.videocam_rounded, 'Reels'),
      (Icons.download_for_offline_rounded, 'Watchlist'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isCenter = i == 2;
          if (isCenter) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToReels(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC107)
                                .withValues(alpha: 0.6),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFC107)
                                .withValues(alpha: 0.25),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final isActive = _navIndexToTab(i) == activeIndex;
          final icon = items[i].$1;
          final label = items[i].$2;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final target = _navIndexToTab(i);
                if (target == -1) {
                  _navigateToWatchlist(context);
                  return;
                }
                onTap?.call(target);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive ? AppColors.accent : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textMuted,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  int _navIndexToTab(int navIndex) {
    switch (navIndex) {
      case 0: return 0;
      case 1: return 1;
      case 3: return -1;
      case 4: return 2;
      default: return -1;
    }
  }
}
