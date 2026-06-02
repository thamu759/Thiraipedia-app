import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/movie.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final String movieId;
  final User? currentUser;
  final VoidCallback onLike;

  const ReviewCard({
    super.key,
    required this.review,
    required this.movieId,
    required this.currentUser,
    required this.onLike,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _showReplies = false;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final isLiked = widget.currentUser != null && r.likedBy.contains(widget.currentUser!.username);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: r.avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(r.avatarUrl)
                    : null,
                backgroundColor: AppColors.bgPanel,
                child: r.avatarUrl.isEmpty ? const Icon(Icons.person, size: 16, color: Colors.white38) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins')),
                    Text(r.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'Poppins')),
                  ],
                ),
              ),
              Row(
                children: List.generate(10, (i) => Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Icon(
                    i < r.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.accent,
                    size: 13,
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(r.text, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5, fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(r.timestamp, style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 11, fontFamily: 'Poppins')),
              const Spacer(),
              GestureDetector(
                onTap: widget.onLike,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLiked ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? AppColors.accent : AppColors.textMuted, size: 16),
                      const SizedBox(width: 4),
                      Text('${r.likes}',
                          style: TextStyle(color: isLiked ? AppColors.accent : AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showReplies = !_showReplies),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _showReplies ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: _showReplies ? AppColors.accent : AppColors.textMuted, size: 16),
                      const SizedBox(width: 4),
                      Text('${r.replies.length}',
                          style: TextStyle(color: _showReplies ? AppColors.accent : AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showReplies && r.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: r.replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person, size: 14, color: Colors.white24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reply.author,
                                style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                            const SizedBox(height: 2),
                            Text(reply.body,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          if (_showReplies && widget.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.bgDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _replyController.clear(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
