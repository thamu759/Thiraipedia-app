import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int activeIndex;

  const AppBottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final items = [
      (Icons.home_rounded, Icons.home_outlined),
      (Icons.search_rounded, Icons.search_outlined),
      (Icons.person_rounded, Icons.person_outline),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final isActive = i == activeIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () {
                  if (i == activeIndex) return;
                  if (auth.user == null && i == 2) {
                    Navigator.pushReplacementNamed(context, '/auth');
                    return;
                  }
                  final routes = ['/', '/search', '/profile'];
                  Navigator.pushReplacementNamed(context, routes[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive ? item.$1 : item.$2,
                    color: isActive ? AppColors.accent : AppColors.textMuted,
                    size: 26,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
