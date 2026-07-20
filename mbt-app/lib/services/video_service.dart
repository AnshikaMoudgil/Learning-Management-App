import 'api_client.dart';

class PlaybackAsset {
  final String? id;
  final String provider;
  final String? mimeType;
  final double? duration;
  final int? width;
  final int? height;
  final String? thumbnailUrl;

  PlaybackAsset({
    this.id,
    required this.provider,
    this.mimeType,
    this.duration,
    this.width,
    this.height,
    this.thumbnailUrl,
  });

  factory PlaybackAsset.fromJson(Map<String, dynamic> json) {
    return PlaybackAsset(
      id: json['id'] as String?,
      provider: json['provider'] as String,
      mimeType: json['mime_type'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      width: json['width'] as int?,
      height: json['height'] as int?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

class PlaybackWatermark {
  final String userName;
  final String? email;
  final String timestamp;
  final String sessionId;
  final int rotationSeconds;
  final Map<String, dynamic> opacityRange;
  final String positionStrategy;
  final String seed;

  PlaybackWatermark({
    required this.userName,
    this.email,
    required this.timestamp,
    required this.sessionId,
    required this.rotationSeconds,
    required this.opacityRange,
    required this.positionStrategy,
    required this.seed,
  });

  factory PlaybackWatermark.fromJson(Map<String, dynamic> json) {
    return PlaybackWatermark(
      userName: json['userName'] as String,
      email: json['email'] as String?,
      timestamp: json['timestamp'] as String,
      sessionId: json['sessionId'] as String,
      rotationSeconds: (json['rotationSeconds'] as num).toInt(),
      opacityRange: Map<String, dynamic>.from(json['opacityRange'] as Map),
      positionStrategy: json['positionStrategy'] as String,
      seed: json['seed'] as String,
    );
  }
}

class PlaybackInfo {
  final String playbackUrl;
  final int? expiresIn;
  final PlaybackAsset asset;
  final PlaybackWatermark? watermark;

  PlaybackInfo({
    required this.playbackUrl,
    this.expiresIn,
    required this.asset,
    this.watermark,
  });

  factory PlaybackInfo.fromJson(Map<String, dynamic> json) {
    return PlaybackInfo(
      playbackUrl: json['playbackUrl'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      asset: PlaybackAsset.fromJson(json['asset'] as Map<String, dynamic>),
      watermark: json['watermark'] != null
          ? PlaybackWatermark.fromJson(json['watermark'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VideoService {
  final ApiClient _api = ApiClient();

  Future<PlaybackInfo> getPlaybackInfoForLesson(String lessonId) async {
    final result = await _api.get('/api/v1/video/playback/$lessonId');
    return PlaybackInfo.fromJson(result as Map<String, dynamic>);
  }

  Future<String> getPlaybackUrlForLesson(String lessonId) async {
    final result = await _api.get('/api/v1/video/proxy/$lessonId');
    return (result as Map<String, dynamic>)['playbackUrl'] as String;
  }
}
