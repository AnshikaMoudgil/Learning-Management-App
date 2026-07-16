import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingNumber;
  final String password;
  final String? joinUrl;
  final String signature;
  final String displayName;
  final String zoomAppKey;

  const MeetingScreen({
    Key? key,
    required this.meetingNumber,
    required this.password,
    this.joinUrl,
    required this.signature,
    required this.displayName,
    required this.zoomAppKey,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  void initState() {
    super.initState();
    _openMeeting();
  }

  Future<void> _openMeeting() async {
    if (widget.joinUrl != null && widget.joinUrl!.isNotEmpty) {
      final uri = Uri.tryParse(widget.joinUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    final fallbackUrl = 'https://zoom.us/j/${widget.meetingNumber}?pwd=${widget.password}';
    final uri = Uri.parse(fallbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Connecting to Meeting'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Redirecting to Zoom...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meeting: ${widget.meetingNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
