/// Represents a video quality URL.
class VideoQalityUrls {
  /// Creates a [VideoQalityUrls].
  VideoQalityUrls({
    required this.quality,
    required this.url,
  });

  /// The quality level (e.g., 720, 1080).
  int quality;

  /// The URL for this quality.
  String url;

  @override
  String toString() => 'VideoQalityUrls(quality: $quality, urls: $url)';
}
