import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OttCalendarScreen extends StatelessWidget {
  const OttCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTT Calendar')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('OTT Release Calendar',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Track OTT releases',
                style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
