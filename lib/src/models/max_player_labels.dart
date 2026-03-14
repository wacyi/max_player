/// Labels displayed in the video player UI.
///
/// All labels have sensible English defaults. Override any label
/// to localize the player for your app's language.
///
/// ```dart
/// MaxPlayerLabels(
///   play: 'تشغيل',
///   pause: 'إيقاف',
///   retry: 'إعادة المحاولة',
///   seconds: 'ثانية',
/// )
/// ```
class MaxPlayerLabels {
  /// Creates a [MaxPlayerLabels] with customizable strings.
  const MaxPlayerLabels({
    this.play = 'Play',
    this.pause = 'Pause',
    this.mute = 'Mute',
    this.unmute = 'Unmute',
    this.settings = 'Settings',
    this.fullscreen = 'Fullscreen',
    this.exitFullScreen = 'Exit full screen',
    this.loopVideo = 'Loop Video',
    this.playbackSpeed = 'Playback speed',
    this.quality = 'Quality',
    this.optionEnabled = 'on',
    this.optionDisabled = 'off',
    this.error = 'Error while playing video',
    this.retry = 'Retry',
    this.seconds = 'Sec',
    this.bufferingTimeout = 'Buffering timeout exceeded.',
  });

  /// Label for the play button tooltip.
  final String play;

  /// Label for the pause button tooltip.
  final String pause;

  /// Label for the mute button tooltip.
  final String mute;

  /// Label for the unmute button tooltip.
  final String unmute;

  /// Label for the settings button tooltip.
  final String settings;

  /// Label for the fullscreen button tooltip.
  final String fullscreen;

  /// Label for the exit fullscreen button tooltip.
  final String exitFullScreen;

  /// Label for the loop video option.
  final String loopVideo;

  /// Label for the playback speed option.
  final String playbackSpeed;

  /// Label for the quality option.
  final String quality;

  /// Label shown when an option is enabled.
  final String optionEnabled;

  /// Label shown when an option is disabled.
  final String optionDisabled;

  /// Label shown when a video error occurs.
  final String error;

  /// Label for the retry button on error.
  final String retry;

  /// Unit label for seek duration (e.g. "10 Sec").
  final String seconds;

  /// Message shown when buffering times out.
  final String bufferingTimeout;

  /// Creates a copy with the given fields replaced.
  MaxPlayerLabels copyWith({
    String? play,
    String? pause,
    String? mute,
    String? unmute,
    String? settings,
    String? fullscreen,
    String? exitFullScreen,
    String? loopVideo,
    String? playbackSpeed,
    String? quality,
    String? optionEnabled,
    String? optionDisabled,
    String? error,
    String? retry,
    String? seconds,
    String? bufferingTimeout,
  }) {
    return MaxPlayerLabels(
      play: play ?? this.play,
      pause: pause ?? this.pause,
      mute: mute ?? this.mute,
      unmute: unmute ?? this.unmute,
      settings: settings ?? this.settings,
      fullscreen: fullscreen ?? this.fullscreen,
      exitFullScreen: exitFullScreen ?? this.exitFullScreen,
      loopVideo: loopVideo ?? this.loopVideo,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      quality: quality ?? this.quality,
      optionEnabled: optionEnabled ?? this.optionEnabled,
      optionDisabled: optionDisabled ?? this.optionDisabled,
      error: error ?? this.error,
      retry: retry ?? this.retry,
      seconds: seconds ?? this.seconds,
      bufferingTimeout: bufferingTimeout ?? this.bufferingTimeout,
    );
  }
}
