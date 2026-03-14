part of 'max_video_controller.dart';

class _MaxVideoController extends _MaxUiController {
  Timer? showOverlayTimer;
  Timer? showOverlayTimer1;

  bool isOverlayVisible = true;
  bool isLooping = false;
  bool isFullScreen = false;
  bool isvideoPlaying = false;

  /// Seek video to a duration.
  Future<void> seekTo(Duration moment) async {
    await _videoCtr!.seekTo(moment);
  }

  /// Seek video forward by the duration.
  Future<void> seekForward(Duration videoSeekDuration) async {
    await seekTo(_videoCtr!.value.position + videoSeekDuration);
  }

  /// Seek video backward by the duration.
  Future<void> seekBackward(Duration videoSeekDuration) async {
    await seekTo(_videoCtr!.value.position - videoSeekDuration);
  }

  /// Toggle mute.
  Future<void> toggleMute() async {
    isMute = !isMute;
    if (isMute) {
      await mute();
    } else {
      await unMute();
    }
  }

  /// Mute the video.
  Future<void> mute() async {
    await setVolume(0);
    update(['volume']);
    update(['update-all']);
  }

  /// Unmute the video.
  Future<void> unMute() async {
    await setVolume(1);
    update(['volume']);
    update(['update-all']);
  }

  /// Set volume between 0.0 and 1.0.
  Future<void> setVolume(double volume) async {
    await _videoCtr?.setVolume(volume);
    if (volume <= 0) {
      isMute = true;
    } else {
      isMute = false;
    }
    update(['volume']);
    update(['update-all']);
  }

  /// Control play/pause.
  Future<void> playVideo({required bool play}) async {
    isvideoPlaying = play;
    if (isvideoPlaying) {
      isShowOverlay(true);
      await _videoCtr?.play();
      isShowOverlay(false, delay: const Duration(seconds: 1));
    } else {
      isShowOverlay(true);
      await _videoCtr?.pause();
    }
  }

  /// Toggle play/pause.
  void togglePlayPauseVideo() {
    isvideoPlaying = !isvideoPlaying;
    maxVideoStateChanger(
      isvideoPlaying ? MaxVideoState.playing : MaxVideoState.paused,
    );
  }

  /// Toggle video player controls overlay.
  // ignore: avoid_positional_boolean_parameters
  void isShowOverlay(bool val, {Duration? delay}) {
    showOverlayTimer1?.cancel();
    showOverlayTimer1 = Timer(delay ?? Duration.zero, () {
      if (isOverlayVisible != val) {
        isOverlayVisible = val;
        update(['overlay']);
        update(['update-all']);
      }
    });
  }

  /// Toggle overlay visibility.
  void toggleVideoOverlay() {
    if (!isOverlayVisible) {
      isOverlayVisible = true;
      update(['overlay']);
      update(['update-all']);
      return;
    }
    if (isOverlayVisible) {
      isOverlayVisible = false;
      update(['overlay']);
      update(['update-all']);
      showOverlayTimer?.cancel();
      showOverlayTimer = Timer(const Duration(seconds: 3), () {
        if (isOverlayVisible) {
          isOverlayVisible = false;
          update(['overlay']);
          update(['update-all']);
        }
      });
    }
  }

  /// Set playback speed from a string like '1.5x' or 'Normal'.
  Future<void> setVideoPlayBack(String speed) async {
    late double pickedSpeed;

    if (speed == 'Normal') {
      pickedSpeed = 1.0;
      _currentPlaybackSpeed = 1.0;
    } else {
      pickedSpeed = double.parse(speed.split('x').first);
      _currentPlaybackSpeed = pickedSpeed;
    }
    await _videoCtr?.setPlaybackSpeed(pickedSpeed);
  }

  /// Set playback speed directly as a double value.
  Future<void> setPlaybackSpeed(double speed) async {
    _currentPlaybackSpeed = speed;
    await _videoCtr?.setPlaybackSpeed(speed);
    update(['update-all']);
  }

  /// The current playback speed.
  double get currentSpeed => _currentPlaybackSpeed;

  /// Set video looping.
  Future<void> setLooping({required bool isLooped}) async {
    isLooping = isLooped;
    await _videoCtr?.setLooping(isLooping);
  }

  /// Toggle video looping.
  Future<void> toggleLooping() async {
    isLooping = !isLooping;
    await _videoCtr?.setLooping(isLooping);
    update();
    update(['update-all']);
  }

  /// Enable fullscreen mode.
  Future<void> enableFullScreen(String tag) async {
    maxLog('-full-screen-enable-entred');
    if (!isFullScreen) {
      if (onToggleFullScreen != null) {
        await onToggleFullScreen!(true);
      } else {
        await Future.wait([
          SystemChrome.setPreferredOrientations(
            [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
          ),
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
        ]);
      }

      _enableFullScreenView(tag);
      isFullScreen = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        update(['full-screen']);
        update(['update-all']);
      });
    }
  }

  /// Disable fullscreen mode.
  Future<void> disableFullScreen(
    BuildContext context,
    String tag, {
    bool enablePop = true,
  }) async {
    maxLog('-full-screen-disable-entred');
    if (isFullScreen) {
      if (onToggleFullScreen != null) {
        await onToggleFullScreen!(false);
      } else {
        await Future.wait([
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]),
          SystemChrome.setPreferredOrientations(DeviceOrientation.values),
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
        ]);
      }

      if (context.mounted && enablePop) _exitFullScreenView(context, tag);
      isFullScreen = false;
      update(['full-screen']);
      update(['update-all']);
    }
  }

  void _exitFullScreenView(BuildContext context, String tag) {
    maxLog('popped-full-screen');
    Navigator.of(fullScreenContext).pop();
  }

  void _enableFullScreenView(String tag) {
    if (!isFullScreen) {
      maxLog('full-screen-enabled');

      unawaited(Navigator.push<void>(
        mainContext,
        PageRouteBuilder<void>(
          fullscreenDialog: true,
          pageBuilder: (context, _, __) => FullScreenView(
            tag: tag,
            controller: this as MaxVideoController,
          ),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
        ),
      ),);
    }
  }

  /// Calculates video `position` or `duration` as a formatted string.
  String calculateVideoDuration(Duration duration) {
    final totalHour = duration.inHours == 0 ? '' : '${duration.inHours}:';
    final totalMinute = duration.toString().split(':')[1];
    final totalSeconds =
        (duration - Duration(minutes: duration.inMinutes))
            .inSeconds
            .toString()
            .padLeft(2, '0');
    final videoLength = '$totalHour$totalMinute:$totalSeconds';
    return videoLength;
  }
}
