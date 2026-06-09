import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/cine_update.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_colors.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with TickerProviderStateMixin {
  late PageController _pageCtrl;
  List<CineUpdate> _items = [];
  final Set<String> _likedIds = {};
  final Map<String, AnimationController> _likeAnimCtrls = {};

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _loadUpdates();
  }

  void _loadUpdates() {
    final mp = context.read<MovieProvider>();
    _items = List.from(mp.cineUpdates)..shuffle();
    if (_items.isEmpty) {
      mp.loadCineUpdates().then((_) {
        if (mounted) {
          setState(() => _items = List.from(mp.cineUpdates)..shuffle());
        }
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final ctrl in _likeAnimCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  AnimationController _getLikeAnimCtrl(String id) {
    if (_likeAnimCtrls.containsKey(id)) {
      return _likeAnimCtrls[id]!;
    }
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    ctrl.addListener(() => setState(() {}));
    ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) ctrl.reverse();
    });
    _likeAnimCtrls[id] = ctrl;
    return ctrl;
  }

  void _toggleLike(String id) {
    final ctrl = _getLikeAnimCtrl(id);
    ctrl.forward(from: 0);
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  void _shareReel(CineUpdate item) {
    final text = '🎬 ${item.title}\n\n${item.body}\n\n📽️ Movie: ${item.movieName}\n📰 ${item.category}\n\nvia ThiraiPedia';
    SharePlus.instance.share(ShareParams(text: text));
  }

  Color _categoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'BREAKING':
        return const Color(0xFFE53935);
      case 'NEWS':
        return const Color(0xFF1E88E5);
      case 'REVIEW':
        return const Color(0xFF43A047);
      case 'INTERVIEW':
        return const Color(0xFF8E24AA);
      case 'BOX OFFICE':
        return const Color(0xFFFF8F00);
      case 'RUMOR':
        return const Color(0xFFFF6D00);
      case 'UPDATE':
        return const Color(0xFF00ACC1);
      default:
        return AppColors.accent;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'BREAKING':
        return Icons.bolt_rounded;
      case 'NEWS':
        return Icons.newspaper_rounded;
      case 'REVIEW':
        return Icons.star_rounded;
      case 'INTERVIEW':
        return Icons.mic_rounded;
      case 'BOX OFFICE':
        return Icons.monetization_on_rounded;
      case 'RUMOR':
        return Icons.auto_awesome_rounded;
      case 'UPDATE':
        return Icons.update_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.yellow),
              const SizedBox(height: 16),
              Text('Loading Reels...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            onPageChanged: (_) {},
            itemBuilder: (context, index) => _buildReel(_items[index]),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            child: _buildTopBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildReel(CineUpdate item) {
    final catColor = _categoryColor(item.category);
    final isLiked = _likedIds.contains(item.id);
    final displayLikes = item.likes + (isLiked ? 1 : 0);
    final animCtrl = _getLikeAnimCtrl(item.id);
    final scale = 1.0 + (animCtrl.value * 0.35);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (item.imageUrl.isNotEmpty)
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.3, 0.3, 0.3, 0, -0.2,
              0.3, 0.3, 0.3, 0, -0.2,
              0.3, 0.3, 0.3, 0, -0.2,
              0, 0, 0, 0.6, 0,
            ]),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.bgDark),
              errorWidget: (_, _, _) => Container(color: AppColors.bgDark),
            ),
          )
        else
          Container(color: AppColors.bgDark),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 80,
          bottom: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: catColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_categoryIcon(item.category), color: catColor, size: 10),
                        const SizedBox(width: 4),
                        Text(item.category.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: catColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.movieName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(item.body,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 160,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(item.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: animCtrl,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isLiked
                                    ? const Color(0xFFE53935).withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                              color: isLiked ? const Color(0xFFE53935) : Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text('$displayLikes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _shareReel(item),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text('Share',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          bottom: 36,
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.5), size: 12),
              const SizedBox(width: 4),
              Text(item.timestamp,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
