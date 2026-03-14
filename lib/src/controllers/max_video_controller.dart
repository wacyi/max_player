import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:max_player/max_player.dart';
import 'package:max_player/src/utils/logger.dart';
import 'package:max_player/src/utils/video_apis.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'max_base_controller.dart';
part 'max_control_controller.dart';
part 'max_gestures_controller.dart';
part 'max_ui_controller.dart';
part 'max_video_quality_controller.dart';

/// Internal video controller managing playback, state, and gestures.
class MaxVideoController extends _MaxGesturesController {
  /// The underlying [VideoPlayerController].
  VideoPlayerController? get videoCtr => _videoCtr;

  /// The current [MaxVideoState].
  MaxVideoState get maxVideoState => _maxVideoState;

  /// The type of video source.
  MaxVideoPlayerType get videoPlayerType => _videoPlayerType;

  /// The current playback speed as a formatted string (legacy).
  String get currentPaybackSpeed => '${_currentPlaybackSpeed}x';

  /// The current [Duration] of the video.
  Duration get videoDuration => _videoDuration;

  /// The current playback position.
  Duration get videoPosition => _videoPosition;

  /// Whether the controller has been initialized.
  bool controllerInitialized = false;

  /// The player configuration.
  late MaxPlayerConfig maxPlayerConfig;

  /// The video source configuration.
  late PlayVideoFrom playVideoFrom;

  /// Configure the controller with the given source and config.
  void config({
    required PlayVideoFrom playVideoFrom,
    required MaxPlayerConfig playerConfig,
  }) {
    this.playVideoFrom = playVideoFrom;
    _videoPlayerType = playVideoFrom.playerType;
    maxPlayerConfig = playerConfig;
    autoPlay = playerConfig.autoPlay;
    isLooping = playerConfig.isLooping;
  }

  /// Initialize the video player.
  Future<void> videoInit() async {
    maxLog(_videoPlayerType.toString());
    try {
      if (!_statusStreamController.isClosed) {
        _statusStreamController.add(MaxPlayerStatus.initializing);
      }
      _currentStatus = MaxPlayerStatus.initializing;

      await _initializePlayer();
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooped: isLooping);
      _videoCtr?.addListener(videoListner);

      // Start position stream.
      _startPositionStream(maxPlayerConfig.positionStreamInterval);

      checkAutoPlayVideo();
      controllerInitialized = true;
      notifyListeners();

      update(['update-all']);
    } catch (e) {
      maxVideoStateChanger(MaxVideoState.error);
      update(['errorState']);
      update(['update-all']);
      maxLog('ERROR ON max_PLAYER:  $e');

      emitError(
        MaxPlayerError(
          type: _classifyError(e),
          message: e.toString(),
          exception: e,
        ),
      );

      rethrow;
    }
  }

  MaxPlayerErrorType _classifyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection')) {
      return MaxPlayerErrorType.network;
    }
    if (message.contains('format') || message.contains('codec')) {
      return MaxPlayerErrorType.format;
    }
    if (message.contains('not found') ||
        message.contains('404') ||
        message.contains('source')) {
      return MaxPlayerErrorType.source;
    }
    return MaxPlayerErrorType.unknown;
  }

  @override
  void maxVideoStateChanger(MaxVideoState? val, {bool updateUi = true}) {
    super.maxVideoStateChanger(val, updateUi: updateUi);
    if (val != null) {
      maxStateListner();
    }
  }

  @override
  void _startBufferingTimeout() {
    _cancelBufferingTimeout();
    _bufferingTimeoutTimer = Timer(
      maxPlayerConfig.bufferingTimeoutDuration,
      () {
        if (isBuffering) {
          emitError(
            MaxPlayerError(
              type: MaxPlayerErrorType.timeout,
              message: maxPlayerLabels.bufferingTimeout,
            ),
          );
          maxVideoStateChanger(MaxVideoState.error);
        }
      },
    );
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case MaxVideoPlayerType.network:
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(playVideoFrom.dataSource!),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = playVideoFrom.dataSource;
      case MaxVideoPlayerType.networkQualityUrls:
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: playVideoFrom.videoQualityUrls!,
        );
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;
      case MaxVideoPlayerType.youtube:
        final urls = await getVideoQualityUrlsFromYoutube(
          playVideoFrom.dataSource!,
          playVideoFrom.live,
        );
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: urls,
        );
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;
      case MaxVideoPlayerType.vimeo:
        await getQualityUrlsFromVimeoId(
          playVideoFrom.dataSource!,
          hash: playVideoFrom.hash,
        );
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;
      case MaxVideoPlayerType.asset:
        _videoCtr = VideoPlayerController.asset(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          package: playVideoFrom.package,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );
        playingVideoUrl = playVideoFrom.dataSource;
      case MaxVideoPlayerType.file:
        _videoCtr = VideoPlayerController.file(
          playVideoFrom.file! as File,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );
      case MaxVideoPlayerType.vimeoPrivateVideos:
        await getQualityUrlsFromVimeoPrivateId(
          playVideoFrom.dataSource!,
          playVideoFrom.httpHeaders,
        );
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;
    }
  }

  /// Handle keyboard events.
  void onKeyBoardEvents({
    required KeyEvent event,
    required BuildContext appContext,
    required String tag,
  }) {}

  /// Listen to video state changes and act accordingly.
  void maxStateListner() {
    maxLog(_maxVideoState.toString());
    switch (_maxVideoState) {
      case MaxVideoState.playing:
        if (maxPlayerConfig.wakelockEnabled) unawaited(WakelockPlus.enable());
        unawaited(playVideo(play: true));
      case MaxVideoState.paused:
        if (maxPlayerConfig.wakelockEnabled) unawaited(WakelockPlus.disable());
        unawaited(playVideo(play: false));
      case MaxVideoState.loading:
        isShowOverlay(true);
      case MaxVideoState.error:
        if (maxPlayerConfig.wakelockEnabled) unawaited(WakelockPlus.disable());
        unawaited(playVideo(play: false));
    }
  }

  /// Check whether video should be auto-played initially.
  void checkAutoPlayVideo() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (autoPlay && (isVideoUiBinded ?? false)) {
        maxVideoStateChanger(MaxVideoState.playing);
      } else {
        maxVideoStateChanger(MaxVideoState.paused);
      }
    });
  }

  /// Change the current video source.
  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    required MaxPlayerConfig playerConfig,
  }) async {
    _videoCtr?.removeListener(videoListner);
    maxVideoStateChanger(MaxVideoState.paused);
    maxVideoStateChanger(MaxVideoState.loading);
    vimeoOrVideoUrls = [];
    config(playVideoFrom: playVideoFrom, playerConfig: playerConfig);
    await videoInit();
  }

  /// Retry loading the current video source after an error.
  Future<void> retry() async {
    maxVideoStateChanger(MaxVideoState.loading);
    _videoCtr?.removeListener(videoListner);
    await _videoCtr?.dispose();
    _videoCtr = null;
    controllerInitialized = false;
    update(['update-all']);
    await videoInit();
  }

  @override
  void dispose() {
    _disposeStreams();
    super.dispose();
  }
}
