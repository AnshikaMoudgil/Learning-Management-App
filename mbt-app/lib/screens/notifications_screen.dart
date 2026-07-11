import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Notifications', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Center(
        child: Text('No new notifications.', style: TextStyle(color: AppColors.textLight)),
      ),
    );
  }
}
