import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/community_thread.dart';
import '../../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CommunityProvider>().fetchThreads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, cp, _) {
          if (cp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cp.threads.isEmpty) {
            return const Center(
              child: Text('No discussions yet. Start one!',
                  style: TextStyle(color: AppTheme.textMuted)),
            );
          }
          return RefreshIndicator(
            onRefresh: () => cp.fetchThreads(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cp.threads.length,
              itemBuilder: (context, i) {
                final thread = cp.threads[i];
                return _threadCard(context, thread);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _threadCard(BuildContext context, CommunityThread thread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    CachedNetworkImageProvider(thread.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thread.author,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(thread.role,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(thread.tag,
                    style: const TextStyle(
                        color: AppTheme.primaryColor, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(thread.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(thread.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.favorite_border,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text('${thread.likes}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text('${thread.replies.length}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
              const Spacer(),
              Text(thread.timestamp,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    String tag = 'General';
    final tags = ['General', 'Recommendations', 'Sound Design', 'Discussion'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('New Discussion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration:
                    const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtl,
                maxLines: 4,
                decoration:
                    const InputDecoration(labelText: 'Body'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tag,
                items: tags
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => tag = v ?? 'General',
                decoration:
                    const InputDecoration(labelText: 'Tag'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtl.text.isEmpty ||
                  bodyCtl.text.isEmpty) return;
              final auth = context.read<AuthProvider>();
              context
                  .read<CommunityProvider>()
                  .createThread(
                      title: titleCtl.text,
                      body: bodyCtl.text,
                      tag: tag,
                      token: auth.token);
              Navigator.pop(ctx);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
