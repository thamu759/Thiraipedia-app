import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/watchlist/watchlist_screen.dart';
import 'screens/coming_soon/coming_soon_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/lists/lists_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/ott_calendar/ott_calendar_screen.dart';
import 'screens/articles/articles_screen.dart';
import 'screens/games/quiz_screen.dart';
import 'screens/games/spin_wheel_screen.dart';
import 'screens/games/blind_frame_screen.dart';
import 'screens/games/mood_matcher_screen.dart';
import 'screens/legal/legal_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/movie_details/actor_screen.dart';
import 'screens/lists/list_detail_screen.dart';
import 'screens/articles/article_detail_screen.dart';

Route _smoothRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

class ThiraiPediaApp extends StatelessWidget {
  const ThiraiPediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThiraiPedia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        final pages = <String, Widget>{
          '/': const HomeScreen(),
          '/search': const SearchScreen(),
          '/auth': const AuthScreen(),
          '/watchlist': const WatchlistScreen(),
          '/coming-soon': const ComingSoonScreen(),
          '/profile': const ProfileScreen(),
          '/community': const CommunityScreen(),
          '/admin': const AdminScreen(),
          '/lists': const ListsScreen(),
          '/leaderboard': const LeaderboardScreen(),
          '/ott-calendar': const OttCalendarScreen(),
          '/articles': const ArticlesScreen(),
          '/quiz': const QuizScreen(),
          '/wheel': const SpinWheelScreen(),
          '/blind-frame': const BlindFrameScreen(),
          '/mood-matcher': const MoodMatcherScreen(),
          '/privacy': const LegalScreen(page: 'privacy'),
          '/terms': const LegalScreen(page: 'terms'),
          '/about': const AboutScreen(),
          '/contact': const ContactScreen(),
          '/article-detail': const ArticleDetailScreen(),
          '/list-detail': const ListDetailScreen(),
          '/actor': const ActorScreen(),
        };
        final page = pages[settings.name];
        if (page != null) return _smoothRoute(page);
        return null;
      },
    );
  }
}
