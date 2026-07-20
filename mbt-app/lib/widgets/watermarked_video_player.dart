import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/video_service.dart';

class WatermarkedVideoPlayer extends StatefulWidget {
  final String lessonId;
  const WatermarkedVideoPlayer({Key? key, required this.lessonId}) : super(key: key);

  @override
  State<WatermarkedVideoPlayer> createState() => _WatermarkedVideoPlayerState();
}

class _WatermarkedVideoPlayerState extends State<WatermarkedVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  PlaybackInfo? _playbackInfo;
  bool _isLoading = true;
  bool _isYouTube = false;
  String? _error;
  final List<_WatermarkData> _watermarks = [];

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final service = VideoService();
      final info = await service.getPlaybackInfoForLesson(widget.lessonId);

      final url = info.playbackUrl;
      final uri = Uri.parse(url);
      final host = uri.host;

      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        setState(() {
          _playbackInfo = info;
          _isYouTube = true;
          _isLoading = false;
        });
        return;
      }

      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();

      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        allowFullScreen: false,
        aspectRatio: controller.value.aspectRatio,
      );

      _watermarks.add(_WatermarkData(
        alignment: Alignment.center,
        opacity: 0.04,
        rotation: 0.61,
      ));

      setState(() {
        _playbackInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isYouTube) {
      return _buildYouTubePlaceholder();
    }
    if (_error != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('Video unavailable', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }
    if (_chewieController == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Chewie(controller: _chewieController!),
        if (_playbackInfo != null) ..._buildWatermarks(),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 20),
            onPressed: _enterFullScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubePlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'External video link',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _launchExternalUrl,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Watch on YouTube'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl() async {
    final url = _playbackInfo?.playbackUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _enterFullScreen() {
    final chewie = _chewieController;
    final info = _playbackInfo;
    if (chewie == null || info == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Chewie(controller: chewie),
              ..._buildWatermarksFor(info),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  List<Widget> _buildWatermarksFor(PlaybackInfo info) {
    final wm = info.watermark;
    if (wm == null) return [];

    final text = '${wm.userName}\n${wm.email ?? ''}\n${wm.timestamp}\nSession: ${wm.sessionId}';

    return _watermarks.map((data) {
      return Positioned.fill(
        child: IgnorePointer(
          child: Transform.rotate(
            angle: data.rotation,
            child: Align(
              alignment: data.alignment,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(data.opacity),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 2,
                  letterSpacing: 0,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildWatermarks() => _buildWatermarksFor(_playbackInfo!);
}

class _WatermarkData {
  Alignment alignment;
  double opacity;
  double rotation;

  _WatermarkData({
    required this.alignment,
    required this.opacity,
    required this.rotation,
  });
}
