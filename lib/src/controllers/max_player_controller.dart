import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:max_player/max_player.dart';
import 'package:max_player/src/controllers/max_video_controller.dart';
import 'package:max_player/src/utils/logger.dart';
import 'package:max_player/src/utils/video_apis.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Public-facing controller for the max video player.
///
/// Use this controller to interact with the player programmatically.
///
/// ```dart
/// final controller = MaxPlayerController(
///   playVideoFrom: PlayVideoFrom.network('https://example.com/video.mp4'),
/// );
/// await controller.initialise();
/// controller.play();
/// ```
class MaxPlayerController {
  /// Creates a [MaxPlayerController].
  MaxPlayerController({
    required this.playVideoFrom,
    this.maxPlayerConfig = const MaxPlayerConfig(),
  }) {
    _init();
  }

  late MaxVideoController _ctr;
  late String getTag;
  bool _isCtrInitialised = false;

  Object? _initializationError;

  /// The video source.
  final PlayVideoFrom playVideoFrom;

  /// The player configuration.
  final MaxPlayerConfig maxPlayerConfig;

  void _init() {
    getTag = UniqueKey().toString();
    _ctr = MaxVideoController()
      ..config(
        playVideoFrom: playVideoFrom,
        playerConfig: maxPlayerConfig,
      );
  }

  /// Expose the internal controller for UI binding.
  MaxVideoController get maxVideoController => _ctr;

  /// Initializes the video player.
  ///
  /// If the provided video cannot be loaded, an exception could be thrown.
  Future<void> initialise() async {
    if (!_isCtrInitialised) {
      _init();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        if (!_isCtrInitialised) {
          await _ctr.videoInit();
          maxLog('$getTag Max player Initialized');
        } else {
          maxLog('$getTag Max Player Controller Already Initialized');
        }
      // ignore: avoid_catches_without_on_clauses - need to catch all errors
      } catch (error) {
        maxLog('$getTag Max Player Controller failed to initialize');
        _initializationError = error;
      }
    });
    await _checkAndWaitTillInitialized();
  }

  Future<void> _checkAndWaitTillInitialized() async {
    if (_ctr.controllerInitialized) {
      _isCtrInitialised = true;
      return;
    }

    final error = _initializationError;
    if (error != null) {
      if (error is Exception) {
        throw error;
      }
      if (error is Error) {
        throw error;
      }
      throw Exception(error.toString());
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _checkAndWaitTillInitialized();
  }

  // -- Basic state getters --

  /// Returns the URL of the current playing video.
  String? get videoUrl => _ctr.playingVideoUrl;

  /// Returns `true` if the video player is initialized.
  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;

  /// Returns `true` if the video is playing.
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;

  /// Returns `true` if the video is buffering.
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;

  /// Returns `true` if looping is enabled.
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  /// Returns `true` if the player is in fullscreen mode.
  bool get isFullScreen => _ctr.isFullScreen;

  /// Returns `true` if the video is muted.
  bool get isMute => _ctr.isMute;

  /// The current [MaxVideoState].
  MaxVideoState get videoState => _ctr.maxVideoState;

  /// The underlying [VideoPlayerValue].
  VideoPlayerValue? get videoPlayerValue => _ctr.videoCtr?.value;

  /// The type of video source.
  MaxVideoPlayerType get videoPlayerType => _ctr.videoPlayerType;

  // -- Phase 1b: Position and state --

  /// Returns the total duration of the video.
  Duration get totalVideoLength => _ctr.videoDuration;

  /// Returns the current position of the video.
  Duration get currentVideoPosition => _ctr.videoPosition;

  /// The total duration, or `null` if not yet known.
  Duration? get totalDuration => _ctr.totalDuration;

  /// Current playback progress as a value from 0.0 to 1.0.
  double get progress => _ctr.progress;

  /// Whether the video is currently playing.
  bool get isPlaying => _ctr.isPlaying;

  /// Whether the video is currently paused.
  bool get isPaused => _ctr.isPaused;

  /// Whether the video is currently buffering.
  bool get isBuffering => _ctr.isBuffering;

  /// Stream of the current playback position.
  ///
  /// Emits at the interval configured in
  /// [MaxPlayerConfig.positionStreamInterval] (default: 500ms).
  Stream<Duration> get positionStream => _ctr.positionStream;

  /// Stream of the buffered position.
  Stream<Duration> get bufferedPositionStream =>
      _ctr.bufferedPositionStream;

  /// Stream of player status changes.
  Stream<MaxPlayerStatus> get statusStream => _ctr.statusStream;

  // -- Phase 1c: Playback speed --

  /// The current playback speed.
  double get currentSpeed => _ctr.currentSpeed;

  /// Set the playback speed.
  ///
  /// Common values: 0.5, 0.75, 1.0, 1.25, 1.5, 2.0
  Future<void> setPlaybackSpeed(double speed) => _ctr.setPlaybackSpeed(speed);

  // -- Phase 1d: Error handling --

  /// Stream of errors that occur during playback.
  Stream<MaxPlayerError> get onError => _ctr.onError;

  /// Retry loading the current video source after an error.
  Future<void> retry() => _ctr.retry();

  // -- Play/pause --

  /// Play the video.
  void play() => _ctr.maxVideoStateChanger(MaxVideoState.playing);

  /// Pause the video.
  void pause() => _ctr.maxVideoStateChanger(MaxVideoState.paused);

  /// Toggle play and pause.
  void togglePlayPause() {
    isVideoPlaying ? pause() : play();
  }

  /// Add a listener for video changes.
  void addListener(VoidCallback listener) {
    unawaited(
      _checkAndWaitTillInitialized().then(
        (value) => _ctr.videoCtr?.addListener(listener),
      ),
    );
  }

  /// Remove a registered listener.
  void removeListener(VoidCallback listener) {
    unawaited(
      _checkAndWaitTillInitialized().then(
        (value) => _ctr.videoCtr?.removeListener(listener),
      ),
    );
  }

  // -- Volume --

  /// Mute the video.
  Future<void> mute() async => _ctr.mute();

  /// Unmute the video.
  Future<void> unMute() async => _ctr.unMute();

  /// Toggle the volume between mute and unmute.
  Future<void> toggleVolume() async {
    _ctr.isMute ? await _ctr.unMute() : await _ctr.mute();
  }

  /// Dispose the video player controller.
  void dispose() {
    _isCtrInitialised = false;
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    unawaited(_ctr.videoCtr?.dispose());
    if (maxPlayerConfig.wakelockEnabled) unawaited(WakelockPlus.disable());
    _ctr.dispose();
    maxLog('$getTag Max player Disposed');
  }

  /// Change the current video.
  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    MaxPlayerConfig playerConfig = const MaxPlayerConfig(),
  }) =>
      _ctr.changeVideo(
        playVideoFrom: playVideoFrom,
        playerConfig: playerConfig,
      );

  /// The current double-tap seek duration in seconds.
  int get doubleTapForwardDuration => _ctr.doubleTapForwardSeconds;

  /// Change the double-tap seek duration in seconds.
  set doubleTapForwardDuration(int seconds) =>
      _ctr.doubleTapForwardSeconds = seconds;

  /// Change the double-tap seek duration in seconds (legacy).
  @Deprecated('Use doubleTapForwardDuration setter instead.')
  // ignore: use_setters_to_change_properties - kept for backward compat
  void setDoubeTapForwarDuration(int seconds) =>
      _ctr.doubleTapForwardSeconds = seconds;

  /// Seek to a specific position.
  Future<void> videoSeekTo(Duration moment) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekTo(moment);
  }

  /// Seek forward by the given duration.
  Future<void> videoSeekForward(Duration duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekForward(duration);
  }

  /// Seek backward by the given duration.
  Future<void> videoSeekBackward(Duration duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekBackward(duration);
  }

  /// Perform a right double-tap seek forward.
  Future<void> doubleTapVideoForward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.onRightDoubleTap(seconds: seconds);
  }

  /// Perform a left double-tap seek backward.
  Future<void> doubleTapVideoBackward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.onLeftDoubleTap(seconds: seconds);
  }

  /// Enable fullscreen mode.
  void enableFullScreen() {
    unawaited(_ctr.enableFullScreen(getTag));
  }

  /// Disable fullscreen mode.
  void disableFullScreen(BuildContext context) {
    unawaited(_ctr.disableFullScreen(context, getTag));
  }

  /// Set a listener for video quality changes.
  // ignore: use_setters_to_change_properties - public API method
  void setOnVideoQualityChanged(VoidCallback callback) {
    _ctr.onVimeoVideoQualityChanged = callback;
  }

  /// Get YouTube video quality URLs.
  static Future<List<VideoQalityUrls>?> getYoutubeUrls(
    String youtubeIdOrUrl, {
    bool live = false,
  }) {
    return VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl, live);
  }

  /// Get Vimeo video quality URLs.
  static Future<List<VideoQalityUrls>?> getVimeoUrls(
    String videoId, {
    String? hash,
  }) {
    return VideoApis.getVimeoVideoQualityUrls(videoId, hash);
  }

  /// Hide the overlay.
  void hideOverlay() => _ctr.isShowOverlay(false);

  /// Show the overlay.
  void showOverlay() => _ctr.isShowOverlay(true);
}
