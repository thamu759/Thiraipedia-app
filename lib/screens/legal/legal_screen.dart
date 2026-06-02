import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  final String page;
  const LegalScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final title = page == 'privacy' ? 'Privacy Policy' : 'Terms of Service';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Content loaded from server',
            style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
