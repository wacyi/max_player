import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../max_player.dart';
import '../utils/logger.dart';
import '../utils/video_apis.dart';
import 'max_video_controller.dart'; // File name unchanged, but class is MaxVideoController

class MaxPlayerController {
  late MaxVideoController _ctr;
  late String getTag;
  bool _isCtrInitialised = false;

  Object? _initializationError;

  final PlayVideoFrom playVideoFrom;
  final MaxPlayerConfig maxPlayerConfig;

  /// controller for max player
  MaxPlayerController({
    required this.playVideoFrom,
    this.maxPlayerConfig = const MaxPlayerConfig(),
  }) {
    _init();
  }

  void _init() {
    getTag = UniqueKey().toString();
    // Get.config(enableLog: MaxVideoPlayer.enableGetxLogs); // Removed Get
    _ctr = MaxVideoController()
      ..config(
        playVideoFrom: playVideoFrom,
        playerConfig: maxPlayerConfig,
      );
  }

  /// Expose the internal controller for UI binding
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

    /// If a wrong video is passed to the player, it'll never being loaded.
    if (_initializationError != null) {
      if (_initializationError! is Exception) {
        throw _initializationError! as Exception;
      }
      if (_initializationError! is Error) {
        throw _initializationError! as Error;
      }
      throw Exception(_initializationError.toString());
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await _checkAndWaitTillInitialized();
  }

  /// returns the url of current playing video
  String? get videoUrl => _ctr.playingVideoUrl;

  /// returns true if video player is initialized
  bool get isInitialised => _ctr.videoCtr?.value.isInitialized ?? false;

  /// returns true if video is playing
  bool get isVideoPlaying => _ctr.videoCtr?.value.isPlaying ?? false;

  /// returns true if video is in buffering state
  bool get isVideoBuffering => _ctr.videoCtr?.value.isBuffering ?? false;

  /// returns true if `loop` is enabled
  bool get isVideoLooping => _ctr.videoCtr?.value.isLooping ?? false;

  /// returns true if video is in fullscreen mode
  bool get isFullScreen => _ctr.isFullScreen;

  bool get isMute => _ctr.isMute;

  MaxVideoState get videoState => _ctr.maxVideoState;

  VideoPlayerValue? get videoPlayerValue => _ctr.videoCtr?.value;

  MaxVideoPlayerType get videoPlayerType => _ctr.videoPlayerType;

  // Future<void> initialize() async => _ctr.videoCtr?.initialize;

  //! video positions

  /// Returns the video total duration
  Duration get totalVideoLength => _ctr.videoDuration;

  /// Returns the current position of the video
  Duration get currentVideoPosition => _ctr.videoPosition;

  //! video play/pause

  /// plays the video
  void play() => _ctr.maxVideoStateChanger(MaxVideoState.playing);

  /// pauses the video
  void pause() => _ctr.maxVideoStateChanger(MaxVideoState.paused);

  /// toogle play and pause
  void togglePlayPause() {
    isVideoPlaying ? pause() : play();
  }

  /// Listen to changes in video.
  ///
  /// It only adds a listener if the player is successfully initialized
  void addListener(VoidCallback listener) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.addListener(listener),
    );
  }

  /// Remove registered listeners
  void removeListener(VoidCallback listener) {
    _checkAndWaitTillInitialized().then(
      (value) => _ctr.videoCtr?.removeListener(listener),
    );
  }

  //! volume Controllers

  /// mute the volume of the video
  Future<void> mute() async => _ctr.mute();

  /// unmute the volume of the video
  Future<void> unMute() async => _ctr.unMute();

  /// toggle the volume
  Future<void> toggleVolume() async {
    _ctr.isMute ? await _ctr.unMute() : await _ctr.mute();
  }

  ///Dispose max video player controller
  void dispose() {
    _isCtrInitialised = false;
    _ctr.videoCtr?.removeListener(_ctr.videoListner);
    _ctr.videoCtr?.dispose();
    // _ctr.removeListenerId('maxVideoState', _ctr.maxStateListner); // Removed
    if (maxPlayerConfig.wakelockEnabled) WakelockPlus.disable();
    // Get.delete<MaxGetXVideoController>( // Removed Get.delete
    //   force: true,
    //   tag: getTag,
    // );
    // Since we created it, we should dispose it or let GC handle it?
    // It's a ChangeNotifier now. Ideally we dispose it.
    _ctr.dispose();
    maxLog('$getTag Max player Disposed');
  }

  /// used to change the video
  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    MaxPlayerConfig playerConfig = const MaxPlayerConfig(),
  }) =>
      _ctr.changeVideo(
        playVideoFrom: playVideoFrom,
        playerConfig: playerConfig,
      );

  //Change double tap duration
  void setDoubeTapForwarDuration(int seconds) =>
      _ctr.doubleTapForwardSeconds = seconds;

  ///Jumps to specific position of the video
  Future<void> videoSeekTo(Duration moment) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekTo(moment);
  }

  ///Moves video forward from current duration to `_duration`
  Future<void> videoSeekForward(Duration duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekForward(duration);
  }

  ///Moves video backward from current duration to `_duration`
  Future<void> videoSeekBackward(Duration duration) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.seekBackward(duration);
  }

  ///on right double tap
  Future<void> doubleTapVideoForward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.onRightDoubleTap(seconds: seconds);
  }

  ///on left double tap
  Future<void> doubleTapVideoBackward(int seconds) async {
    await _checkAndWaitTillInitialized();
    if (!_isCtrInitialised) return;
    return _ctr.onLeftDoubleTap(seconds: seconds);
  }

  /// Enables video player to fullscreen mode.
  ///
  /// If onToggleFullScreen is set, you must handle the device
  /// orientation by yourself.
  void enableFullScreen() {
    _ctr.enableFullScreen(getTag);
  }

  /// Disables fullscreen mode.
  ///
  /// If onToggleFullScreen is set, you must handle the device
  /// orientation by yourself.
  void disableFullScreen(BuildContext context) {
    _ctr.disableFullScreen(context, getTag);
  }

  /// listener for the changes in the quality of the video
  void onVideoQualityChanged(VoidCallback callback) {
    _ctr.onVimeoVideoQualityChanged = callback;
  }

  static Future<List<VideoQalityUrls>?> getYoutubeUrls(
    String youtubeIdOrUrl, {
    bool live = false,
  }) {
    return VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl, live);
  }

  static Future<List<VideoQalityUrls>?> getVimeoUrls(
    String videoId, {
    String? hash,
  }) {
    return VideoApis.getVimeoVideoQualityUrls(videoId, hash);
  }

  /// Hide overlay of video
  void hideOverlay() => _ctr.isShowOverlay(false);

  /// Show overlay of video
  void showOverlay() => _ctr.isShowOverlay(true);
}
