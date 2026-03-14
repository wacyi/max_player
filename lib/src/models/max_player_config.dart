import 'package:max_player/src/models/max_player_theme.dart';

/// Configuration for the max video player.
class MaxPlayerConfig {
  /// Creates a [MaxPlayerConfig].
  const MaxPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
    this.wakelockEnabled = true,
    this.videoQualityPriority = const [1080, 720, 360],
    this.theme,
    this.availableSpeeds = const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
    this.positionStreamInterval = const Duration(milliseconds: 500),
    this.bufferingTimeoutDuration = const Duration(seconds: 15),
  });

  /// Whether the video should start playing automatically.
  final bool autoPlay;

  /// Whether the video should loop.
  final bool isLooping;

  /// Whether to force video focus.
  final bool forcedVideoFocus;

  /// Whether to keep the screen on during playback.
  final bool wakelockEnabled;

  /// Initial video quality priority. The first available option will be used,
  /// from start to the end of this list. If all options informed are not
  /// available or if nothing is provided, 360p is used.
  ///
  /// Default value is `[1080, 720, 360]`.
  final List<int> videoQualityPriority;

  /// Theme configuration for the player.
  final MaxPlayerTheme? theme;

  /// Available playback speeds shown in the speed selector.
  ///
  /// Default value is `[0.5, 0.75, 1.0, 1.25, 1.5, 2.0]`.
  final List<double> availableSpeeds;

  /// The interval at which the position stream emits updates.
  ///
  /// Default value is 500 milliseconds.
  final Duration positionStreamInterval;

  /// Duration of buffering before a timeout error is surfaced.
  ///
  /// Default value is 15 seconds.
  final Duration bufferingTimeoutDuration;

  /// Creates a copy with the given fields replaced.
  MaxPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
    bool? wakelockEnabled,
    List<int>? videoQualityPriority,
    MaxPlayerTheme? theme,
    List<double>? availableSpeeds,
    Duration? positionStreamInterval,
    Duration? bufferingTimeoutDuration,
  }) {
    return MaxPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      videoQualityPriority: videoQualityPriority ?? this.videoQualityPriority,
      theme: theme ?? this.theme,
      availableSpeeds: availableSpeeds ?? this.availableSpeeds,
      positionStreamInterval:
          positionStreamInterval ?? this.positionStreamInterval,
      bufferingTimeoutDuration:
          bufferingTimeoutDuration ?? this.bufferingTimeoutDuration,
    );
  }
}
