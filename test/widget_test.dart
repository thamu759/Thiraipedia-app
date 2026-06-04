import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thiraipedia_app/app.dart';
import 'package:thiraipedia_app/providers/auth_provider.dart';
import 'package:thiraipedia_app/providers/movie_provider.dart';
import 'package:thiraipedia_app/providers/watchlist_provider.dart';
import 'package:thiraipedia_app/providers/community_provider.dart';
import 'package:thiraipedia_app/providers/profile_provider.dart';
import 'package:thiraipedia_app/providers/list_provider.dart';
import 'package:thiraipedia_app/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MovieProvider()),
          ChangeNotifierProvider(create: (_) => WatchlistProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ListProvider()),
        ],
        child: const ThiraiPediaApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(AppBottomNav), findsOneWidget);
  });
}
