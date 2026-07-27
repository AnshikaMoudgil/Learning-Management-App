import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
  YoutubePlayerController? _youtubeController;
  final List<_WatermarkData> _watermarks = [];

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        return segments.last;
      }
    }
    if (uri.host.contains('youtu.be')) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        return segments.first;
      }
    }
    return null;
  }

  Future<void> _loadVideo() async {
    try {
      final service = VideoService();
      final info = await service.getPlaybackInfoForLesson(widget.lessonId);

      final url = info.playbackUrl;
      final uri = Uri.tryParse(url);
      if (uri == null) {
        setState(() {
          _playbackInfo = info;
          _error = 'Invalid video URL';
          _isLoading = false;
        });
        return;
      }
      final host = uri.host;

      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        final videoId = _extractYouTubeId(url);
        YoutubePlayerController? controller;
        if (videoId != null) {
          controller = YoutubePlayerController(
            params: const YoutubePlayerParams(
              showControls: true,
              showFullscreenButton: true,
              mute: false,
              privacyEnhancedMode: true,
            ),
          );
          controller.loadVideoById(videoId: videoId);
        }
        setState(() {
          _playbackInfo = info;
          _isYouTube = true;
          _isLoading = false;
          _youtubeController = controller;
        });
        return;
      }

      final videoController = VideoPlayerController.networkUrl(uri);
      await videoController.initialize();

      _videoController = videoController;
      _chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        allowFullScreen: false,
        aspectRatio: videoController.value.aspectRatio,
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
    _youtubeController?.close();
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
      return _buildYouTubePlayer();
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

  Widget _buildYouTubePlayer() {
    if (_youtubeController == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: Text('Could not load video', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _youtubeController!,
      aspectRatio: 16 / 9,
    );
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
