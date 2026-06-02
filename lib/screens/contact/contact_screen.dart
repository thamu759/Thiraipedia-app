import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in touch',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email, color: AppTheme.primaryColor),
              title: Text('support@thiraipedia.com'),
            ),
            ListTile(
              leading:
                  Icon(Icons.chat, color: AppTheme.primaryColor),
              title: Text('Community Forum'),
              subtitle: Text('Post in our Community for help'),
            ),
          ],
        ),
      ),
    );
  }
}
