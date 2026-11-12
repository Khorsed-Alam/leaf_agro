import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications & Alerts')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No new agricultural weather or disease outbreak alerts.'),
          ],
        ),
      ),
    );
  }
}

