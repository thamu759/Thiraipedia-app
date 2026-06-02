import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context
            .read<ProfileProvider>()
            .fetchUser(auth.user!.username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, auth, profile, _) {
        final user = auth.user;
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    CachedNetworkImageProvider(user.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              Text(user.username,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(user.bio,
                    style: const TextStyle(
                        color: AppTheme.textSecondary)),
              ],
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(user.role,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem('Followers',
                      '${user.followers.length}'),
                  _statItem('Following',
                      '${user.following.length}'),
                  _statItem('Lists', '0'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  onPressed: () => _showEditDialog(context, auth),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: AppTheme.primaryColor),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () {
                    auth.logout();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(Icons.admin_panel_settings, 'Admin Panel',
                  '/admin', auth.isAdmin),
              _buildMenuItem(Icons.list, 'My Lists', '/lists', true),
              _buildMenuItem(
                  Icons.info_outline, 'About', '/about', true),
              _buildMenuItem(
                  Icons.privacy_tip, 'Privacy Policy', '/privacy', true),
              _buildMenuItem(
                  Icons.description, 'Terms of Service', '/terms', true),
              _buildMenuItem(
                  Icons.mail_outline, 'Contact', '/contact', true),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(
      IconData icon, String label, String route, bool enabled) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      enabled: enabled,
      onTap: enabled
          ? () => Navigator.pushNamed(context, route)
          : null,
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final bioCtl =
        TextEditingController(text: auth.user?.bio ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bioCtl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                auth.updateProfile({'bio': bioCtl.text});
                Navigator.pop(ctx);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}
