import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SkeletonLoading extends StatefulWidget {
  final Widget child;

  const SkeletonLoading({super.key, required this.child});

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFF1a1a2e),
              Color(0xFF2a2a4e),
              Color(0xFF3a3a5e),
              Color(0xFF2a2a4e),
              Color(0xFF1a1a2e),
            ],
            stops: [
              _ctrl.value - 0.3,
              _ctrl.value - 0.15,
              _ctrl.value,
              _ctrl.value + 0.15,
              _ctrl.value + 0.3,
            ].map((s) => s.clamp(0.0, 1.0)).toList(),
          ).createShader(bounds),
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.only(top: 100),
      child: Column(
        children: [
          // Hero skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerPlaceholder(height: 220, borderRadius: 12),
          ),
          SizedBox(height: 32),
          // Section skeleton
          _SectionSkeleton(),
          SizedBox(height: 24),
          _SectionSkeleton(),
          SizedBox(height: 24),
          _SectionSkeleton(),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: ShimmerPlaceholder(width: 140, height: 20, borderRadius: 4),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (_, _) => Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder(width: 120, height: 13, borderRadius: 3),
                        SizedBox(height: 8),
                        ShimmerPlaceholder(width: 60, height: 11, borderRadius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MovieDetailsSkeleton extends StatelessWidget {
  const MovieDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backdrop skeleton
          const ShimmerPlaceholder(height: 200, borderRadius: 12),
          const SizedBox(height: 16),
          // Poster + info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerPlaceholder(width: 100, height: 150, borderRadius: 10),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerPlaceholder(width: double.infinity, height: 22, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerPlaceholder(width: 120, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerPlaceholder(width: 80, height: 16, borderRadius: 4),
                    SizedBox(height: 16),
                    ShimmerPlaceholder(width: double.infinity, height: 40, borderRadius: 8),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Synopsis skeleton
          const ShimmerPlaceholder(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          const ShimmerPlaceholder(height: 80, borderRadius: 12),
          const SizedBox(height: 24),
          // Cast skeleton
          const ShimmerPlaceholder(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, _) => Container(
                width: 64,
                margin: const EdgeInsets.only(right: 12),
                child: const Column(
                  children: [
                    ShimmerPlaceholder(width: 56, height: 56, borderRadius: 28),
                    SizedBox(height: 6),
                    ShimmerPlaceholder(width: 56, height: 10, borderRadius: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (_, _) => Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              decoration: const BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerPlaceholder(width: 160, height: 14, borderRadius: 3),
                    SizedBox(height: 8),
                    ShimmerPlaceholder(width: 100, height: 12, borderRadius: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: ShimmerPlaceholder(width: 140, height: 20, borderRadius: 4),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (_, _) => Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder(width: 120, height: 13, borderRadius: 3),
                        SizedBox(height: 8),
                        ShimmerPlaceholder(width: 60, height: 11, borderRadius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
