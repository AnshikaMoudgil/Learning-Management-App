import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/sessions_service.dart';
import 'meeting_screen.dart';

class SessionsScreen extends StatefulWidget {
  final String courseId;
  final SessionsService sessionsService;

  const SessionsScreen({
    Key? key,
    required this.courseId,
    required this.sessionsService,
  }) : super(key: key);

  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late Future<List<LiveSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSessions();
  }

  void _refreshSessions() {
    setState(() {
      _sessionsFuture = widget.sessionsService.getSessions(widget.courseId);
    });
  }

  void _joinSession(LiveSession session) async {
    try {
      final joinData = await widget.sessionsService.joinSession(session.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingNumber: joinData['meeting_number'],
            password: joinData['password'] ?? '',
            signature: joinData['signature'],
            displayName: joinData['display_name'],
            zoomAppKey: joinData['zoom_app_key'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSessions,
          ),
        ],
      ),
      body: FutureBuilder<List<LiveSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No live sessions scheduled for this course.'),
            );
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final canJoin =
                  session.status == 'live' ||
                  (session.status == 'scheduled' &&
                      session.startTime.difference(DateTime.now()).inMinutes <=
                          10);

              return Card(
                margin: const EdgeInsets.bottom(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (session.description != null) ...[
                        Text(session.description!),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.startTime.toLocal().toString().substring(
                              0,
                              16,
                            ),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${session.duration} mins',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              session.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: session.status == 'live'
                                ? Colors.green
                                : session.status == 'finished'
                                ? Colors.blueGrey
                                : session.status == 'cancelled'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          if (session.status != 'cancelled' &&
                              session.status != 'finished' &&
                              session.status != 'recording_ready')
                            ElevatedButton(
                              onPressed: canJoin
                                  ? () => _joinSession(session)
                                  : null,
                              child: const Text('Join'),
                            ),
                          if (session.status == 'recording_ready' &&
                              session.recordingUrl != null)
                            ElevatedButton.icon(
                              onPressed: () {
                                // Open recording playback logic
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Recording'),
                            ),
                        ],
                      ),
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
}
