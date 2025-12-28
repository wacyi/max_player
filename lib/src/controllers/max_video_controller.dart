import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../max_player.dart';
import '../utils/logger.dart';
import '../utils/video_apis.dart';

part 'max_base_controller.dart';
part 'max_gestures_controller.dart';
part 'max_ui_controller.dart';
part 'max_control_controller.dart';
part 'max_video_quality_controller.dart';

class MaxVideoController extends _MaxGesturesController {
  ///main videoplayer controller
  VideoPlayerController? get videoCtr => _videoCtr;

  ///maxVideoPlayer state notifier
  MaxVideoState get maxVideoState => _maxVideoState;

  ///vimeo or general --video player type
  MaxVideoPlayerType get videoPlayerType => _videoPlayerType;

  String get currentPaybackSpeed => _currentPaybackSpeed;

  ///
  Duration get videoDuration => _videoDuration;

  ///
  Duration get videoPosition => _videoPosition;

  bool controllerInitialized = false;
  late MaxPlayerConfig maxPlayerConfig;
  late PlayVideoFrom playVideoFrom;
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

  ///*init
  Future<void> videoInit() async {
    ///
    // checkPlayerType();
    maxLog(_videoPlayerType.toString());
    try {
      await _initializePlayer();
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      // Replaced addListenerId with addListener.
      // maxVideoState changes will trigger notifyListeners(), so we just listen generally.
      // However, we need to ensure maxStateListner execution context.
      // Since maxVideoStateChanger calls update which calls notifyListeners,
      // and maxStateListner logic depends on _maxVideoState, we can call it directly inside maxVideoStateChanger?
      // Or just add it as a listener.
      // ISSUE: calling maxStateListner here adds it to general listeners,
      // but maxStateListner might trigger logic that shouldn't run on EVERY update.
      // BUT MaxVideoState only changes rarely.
      // Let's hook it differently: override maxVideoStateChanger.

      // For now, attaching it as a general listener, but ensuring it's robust.
      // Actually, maxVideoStateChanger logic calls update.
      // The original code listed to 'maxVideoState'.
      // I will override maxVideoStateChanger in this class to call maxStateListner directly too?
      // No, let's keep it simple. addListener(maxStateListner) means it runs on ANY update.
      // That might be too much.
      // Better approach: In maxVideoStateChanger (which is in base), we can't easily hook.
      // I will rely on the fact that maxStateListner does a switch on _maxVideoState.
      // If the state hasn't effectively changed to something new that needs action...
      // Original code only fired 'update' on state change.

      // I will remove the listener approach and instead call `maxStateListner` manually
      // whenever `maxVideoStateChanger` changes the state.
      // But `maxVideoStateChanger` is in the base class.
      // I'll override `maxVideoStateChanger`.

      // addListener(maxStateListner); // This would run on video position updates too! BAD.

      checkAutoPlayVideo();
      controllerInitialized = true;
      notifyListeners(); // Replced update()

      update(['update-all']);
      // ignore: unawaited_futures
      Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      maxVideoStateChanger(MaxVideoState.error);
      update(['errorState']);
      update(['update-all']);
      maxLog('ERROR ON max_PLAYER:  $e');
      rethrow;
    }
  }

  @override
  void maxVideoStateChanger(MaxVideoState? val, {bool updateUi = true}) {
    super.maxVideoStateChanger(val, updateUi: updateUi);
    // Call listener logic when state changes
    if (val != null) {
      maxStateListner();
    }
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case MaxVideoPlayerType.network:

        ///
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(playVideoFrom.dataSource!),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = playVideoFrom.dataSource;
        break;
      case MaxVideoPlayerType.networkQualityUrls:
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: playVideoFrom.videoQualityUrls!,
        );

        ///
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;

        break;
      case MaxVideoPlayerType.youtube:
        final urls = await getVideoQualityUrlsFromYoutube(
          playVideoFrom.dataSource!,
          playVideoFrom.live,
        );
        final url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: urls,
        );

        ///
        _videoCtr = VideoPlayerController.networkUrl(
          Uri.parse(url),
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = url;

        break;
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

        break;
      case MaxVideoPlayerType.asset:

        ///
        _videoCtr = VideoPlayerController.asset(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          package: playVideoFrom.package,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );
        playingVideoUrl = playVideoFrom.dataSource;

        break;
      case MaxVideoPlayerType.file:

        ///
        _videoCtr = VideoPlayerController.file(
          playVideoFrom.file!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );

        break;
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

        break;
    }
  }

  ///Listning on keyboard events
  void onKeyBoardEvents({
    required KeyEvent event,
    required BuildContext appContext,
    required String tag,
  }) {}

  ///this func will listne to update id `_maxVideoState`
  void maxStateListner() {
    maxLog(_maxVideoState.toString());
    switch (_maxVideoState) {
      case MaxVideoState.playing:
        if (maxPlayerConfig.wakelockEnabled) WakelockPlus.enable();
        playVideo(true);
        break;
      case MaxVideoState.paused:
        if (maxPlayerConfig.wakelockEnabled) WakelockPlus.disable();
        playVideo(false);
        break;
      case MaxVideoState.loading:
        isShowOverlay(true);
        break;
      case MaxVideoState.error:
        if (maxPlayerConfig.wakelockEnabled) WakelockPlus.disable();
        playVideo(false);
        break;
    }
  }

  ///checkes wether video should be `autoplayed` initially
  void checkAutoPlayVideo() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (autoPlay && (isVideoUiBinded ?? false)) {
        maxVideoStateChanger(MaxVideoState.playing);
      } else {
        maxVideoStateChanger(MaxVideoState.paused);
      }
    });
  }

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
}
