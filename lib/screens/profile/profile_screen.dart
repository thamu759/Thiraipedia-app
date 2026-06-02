import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/html_utils.dart';
import '../../widgets/app_bottom_nav.dart';

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
        context.read<ProfileProvider>().fetchUser(auth.user!.username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, auth, profile, _) {
        final user = auth.user;
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white24, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text('Not logged in',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textMuted,
                        fontSize: 16,
                      )),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/auth'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.accent,
                          AppColors.accentSecondary,
                        ]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Sign In',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomNav(activeIndex: 2),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildStats(user),
                const SizedBox(height: 24),
                _buildActions(auth),
                const SizedBox(height: 24),
                _buildMenu(auth),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNav(activeIndex: 2),
        );
      },
    );
  }

  Widget _buildHeader(dynamic user) {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgCard,
                AppColors.bgDark,
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
            ),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bgDark.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: user.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.bgDark),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.bgDark,
                            child: const Icon(Icons.person,
                                color: Colors.white24, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.bgDark,
                          child: const Icon(Icons.person,
                              color: Colors.white24, size: 40),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Text(user.username,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFDDDDDD),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(user.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textMuted,
                        fontSize: 13,
                      )),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Text(user.role,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: _statItem('Followers', '${user.followers.length}')),
            Container(width: 1, height: 30, color: AppColors.border),
            Expanded(child: _statItem('Following', '${user.following.length}')),
            Container(width: 1, height: 30, color: AppColors.border),
            Expanded(child: _statItem('Lists', '0')),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMuted,
              fontSize: 11,
            )),
      ],
    );
  }

  Widget _buildActions(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditDialog(context, auth),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.textMuted, size: 18),
                    SizedBox(width: 6),
                    Text('Edit Profile',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _confirmLogout(auth),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.textMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(AuthProvider auth) {
    final items = [
      (Icons.admin_panel_settings_outlined, 'Admin Panel', '/admin',
          auth.isAdmin),
      (Icons.favorite_outline_rounded, 'My Lists', '/lists', true),
      (Icons.info_outline_rounded, 'About', '/about', true),
      (Icons.shield_outlined, 'Privacy Policy', '/privacy', true),
      (Icons.description_outlined, 'Terms of Service', '/terms', true),
      (Icons.mail_outline_rounded, 'Contact', '/contact', true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return GestureDetector(
            onTap: item.$4
                ? () => Navigator.pushNamed(context, item.$3)
                : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(item.$1,
                      color: item.$4
                          ? AppColors.textMuted
                          : AppColors.textMuted.withValues(alpha: 0.3),
                      size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item.$2,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: item.$4
                              ? AppColors.textMain
                              : AppColors.textMuted.withValues(alpha: 0.3),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: item.$4
                          ? AppColors.textMuted
                          : AppColors.textMuted.withValues(alpha: 0.3),
                      size: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth) {
    final bioCtl = TextEditingController(text: auth.user?.bio ?? '');
    String? pickedAvatar;
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.accent, size: 22),
              SizedBox(width: 10),
              Text('Edit Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFFDDDDDD),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await pickImage();
                  if (result?.dataUrl != null) {
                    setDState(() => pickedAvatar = result!.dataUrl);
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: pickedAvatar != null
                            ? Image.network(pickedAvatar!, fit: BoxFit.cover)
                            : (auth.user != null && auth.user!.avatarUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: auth.user!.avatarUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) =>
                                        Container(color: AppColors.bgDark),
                                    errorWidget: (_, _, _) => Container(
                                      color: AppColors.bgDark,
                                      child: const Icon(Icons.person,
                                          color: Colors.white24, size: 36),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.bgDark,
                                    child: const Icon(Icons.person,
                                        color: Colors.white24, size: 36),
                                  )),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.black, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final result = await pickImage();
                  if (result?.dataUrl != null) {
                    setDState(() => pickedAvatar = result!.dataUrl);
                  }
                },
                child: const Text('Change Photo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: bioCtl,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write something about yourself...',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              if (uploading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  backgroundColor: AppColors.bgCard,
                  color: AppColors.accent,
                ),
              ],
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: uploading
                  ? null
                  : () async {
                      setDState(() => uploading = true);
                      final data = <String, dynamic>{
                        'bio': bioCtl.text,
                      };
                      if (pickedAvatar != null) {
                        data['avatarUrl'] = pickedAvatar;
                      }
                      await auth.updateProfile(data);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: uploading
                      ? null
                      : LinearGradient(colors: [
                          AppColors.accent,
                          AppColors.accentSecondary,
                        ]),
                  color: uploading ? Colors.grey[800] : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ))
                    : const Text('Save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFFDDDDDD),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            )),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMuted,
              fontSize: 14,
            )),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              auth.logout();
              Navigator.pop(ctx);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Sign Out',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
