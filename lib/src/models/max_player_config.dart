import 'max_player_theme.dart';

class MaxPlayerConfig {
  final bool autoPlay;
  final bool isLooping;
  final bool forcedVideoFocus;
  final bool wakelockEnabled;

  /// Initial video quality priority. The first available option will be used,
  /// from start to the end of this list. If all options informed are not
  /// available or if nothing is provided, 360p is used.
  ///
  /// Default value is [1080, 720, 360]
  final List<int> videoQualityPriority;

  /// Theme configuration for the player.
  final MaxPlayerTheme? theme;

  const MaxPlayerConfig({
    this.autoPlay = true,
    this.isLooping = false,
    this.forcedVideoFocus = false,
    this.wakelockEnabled = true,
    this.videoQualityPriority = const [1080, 720, 360],
    this.theme,
  });

  MaxPlayerConfig copyWith({
    bool? autoPlay,
    bool? isLooping,
    bool? forcedVideoFocus,
    bool? wakelockEnabled,
    List<int>? videoQualityPriority,
    MaxPlayerTheme? theme,
  }) {
    return MaxPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      isLooping: isLooping ?? this.isLooping,
      forcedVideoFocus: forcedVideoFocus ?? this.forcedVideoFocus,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      videoQualityPriority: videoQualityPriority ?? this.videoQualityPriority,
      theme: theme ?? this.theme,
    );
  }
}
