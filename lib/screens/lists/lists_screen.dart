import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/list_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ListProvider>().fetchLists());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ListProvider>(
        builder: (context, lp, _) {
          if (lp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lp.lists.isEmpty) {
            return const Center(
              child: Text('No lists yet. Create one!',
                  style: TextStyle(color: AppTheme.textMuted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lp.lists.length,
            itemBuilder: (context, i) {
              final list = lp.lists[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/list-detail',
                    arguments: list),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.list,
                            color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(list.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (list.description.isNotEmpty)
                              Text(list.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12)),
                            Text('${list.movieIds.length} movies',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textMuted),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('New List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration:
                  const InputDecoration(labelText: 'List Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtl.text.isEmpty) return;
              final auth = context.read<AuthProvider>();
              context
                  .read<ListProvider>()
                  .createList(
                      name: nameCtl.text,
                      description: descCtl.text,
                      token: auth.token);
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
