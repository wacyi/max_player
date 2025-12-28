// ignore_for_file: no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../max_player.dart';
import 'controllers/max_video_controller.dart';
import 'utils/logger.dart';
import 'widgets/double_tap_icon.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/animated_play_pause_icon.dart';

part 'widgets/core/overlays/mobile_bottomsheet.dart';

part 'widgets/core/overlays/mobile_overlay.dart';

part 'widgets/core/overlays/overlays.dart';

part 'widgets/core/max_core_player.dart';

part 'widgets/core/video_gesture_detector.dart';

part 'widgets/full_screen_view.dart';

class MaxVideoPlayer extends ConsumerStatefulWidget {
  final MaxPlayerController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;
  final bool alwaysShowProgressBar;
  final bool matchVideoAspectRatioToFrame;
  final bool matchFrameAspectRatioToVideo;
  final MaxProgressBarConfig maxProgressBarConfig;
  final MaxPlayerLabels maxPlayerLabels;
  final Widget Function(OverLayOptions options)? overlayBuilder;
  final Widget Function()? onVideoError;
  final Widget? videoTitle;
  final Color? backgroundColor;
  final DecorationImage? videoThumbnail;

  /// Optional callback, fired when full screen mode toggles.
  ///
  /// Important: If this method is set, the configuration of [DeviceOrientation]
  /// and [SystemUiMode] is up to you.
  final Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Sets a custom loading widget.
  /// If no widget is informed, a default [CircularProgressIndicator] will be shown.
  final WidgetBuilder? onLoading;

  MaxVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
    this.alwaysShowProgressBar = true,
    this.maxProgressBarConfig = const MaxProgressBarConfig(),
    this.maxPlayerLabels = const MaxPlayerLabels(),
    this.overlayBuilder,
    this.videoTitle,
    this.matchVideoAspectRatioToFrame = false,
    this.matchFrameAspectRatioToVideo = false,
    this.onVideoError,
    this.backgroundColor,
    this.videoThumbnail,
    this.onToggleFullScreen,
    this.onLoading,
  }) : super(key: key) {
    addToUiController();
  }

  static bool enableLogs = false;
  static bool enableGetxLogs = false;

  void addToUiController() {
    // Direct assignment instead of Get.find
    final maxCtr = controller.maxVideoController;

    maxCtr
      ..maxPlayerLabels = maxPlayerLabels
      ..alwaysShowProgressBar = alwaysShowProgressBar
      ..maxProgressBarConfig = maxProgressBarConfig
      ..overlayBuilder = overlayBuilder
      ..videoTitle = videoTitle
      ..onToggleFullScreen = onToggleFullScreen
      ..onLoading = onLoading
      ..videoThumbnail = videoThumbnail;
  }

  @override
  ConsumerState<MaxVideoPlayer> createState() => _MaxVideoPlayerState();
}

class _MaxVideoPlayerState extends ConsumerState<MaxVideoPlayer>
    with TickerProviderStateMixin {
  late MaxVideoController maxCtr;

  // Helper provider to expose the specific controller instance to children via ref.watch if needed,
  // aka a scoped provider.
  // For now, we reuse the controller instance from the widget.
  // To make the entire tree reactive, children should use ChangeNotifierProvider.value logic
  // or pass the controller down.
  // `_MaxCoreVideoPlayer` and parts seem to get the controller via Get.find usually?
  // We need to fix that. They likely rely on `Get.find(tag: ...)`.
  // Since we are removing Get, we must pass the controller down or provide it.

  // We will pass the controller instance to children where possible.
  // OR we define a provider that children can read?
  // The children are in `part` files so they can access `MaxVideoPlayer` scope if passed? No, parts are just code organization.

  // Strategy:
  // Since `part` files call `Get.find`, we MUST replace those `Get.find` calls too.
  // The best way is to construct a Riverpod provider SCOPED to this widget?
  // Riverpod doesn't support scoping easily without `ProviderScope`, which breaks inheritance/overlay things sometimes.
  // Simpler: Passing `maxCtr` to sub-widgets.
  // Sub-widgets currently take `tag`. We can change them to take `MaxVideoController controller`.

  @override
  void initState() {
    super.initState();
    maxCtr = widget.controller.maxVideoController..isVideoUiBinded = true;

    if (maxCtr.wasVideoPlayingOnUiDispose ?? false) {
      maxCtr.maxVideoStateChanger(MaxVideoState.playing, updateUi: false);
    }
  }

  @override
  void dispose() {
    super.dispose();

    ///Checking if the video was playing when this widget is disposed
    if (maxCtr.isvideoPlaying) {
      maxCtr.wasVideoPlayingOnUiDispose = true;
    } else {
      maxCtr.wasVideoPlayingOnUiDispose = false;
    }
    maxCtr
      ..isVideoUiBinded = false
      ..maxVideoStateChanger(MaxVideoState.paused, updateUi: false);

    // maxCtr.keyboardFocus?.unfocus();
    // maxCtr.keyboardFocusOnFullScreen?.unfocus();
    maxCtr.hoverOverlayTimer?.cancel();
    maxCtr.showOverlayTimer?.cancel();
    maxCtr.showOverlayTimer1?.cancel();
    maxCtr.leftDoubleTapTimer?.cancel();
    maxCtr.rightDoubleTapTimer?.cancel();
    maxLog('local MaxVideoPlayer disposed');
  }

  ///
  double _frameAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final circularProgressIndicator = _thumbnailAndLoadingWidget();
    maxCtr.mainContext = context;

    final _videoErrorWidget = AspectRatio(
      aspectRatio: _frameAspectRatio,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.yellow,
              size: 32,
            ),
            const SizedBox(height: 20),
            Text(
              widget.maxPlayerLabels.error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );

    // Replace GetBuilder with ListenableBuilder (built-in Flutter) since MaxVideoController is ChangeNotifier
    // or use ref.watch if we put it in a provider.
    // ListenableBuilder is simpler here since we have the instance.
    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) {
        _frameAspectRatio = widget.matchFrameAspectRatioToVideo
            ? maxCtr.videoCtr?.value.aspectRatio ?? widget.frameAspectRatio
            : widget.frameAspectRatio;
        return Center(
          child: ColoredBox(
            color: widget.backgroundColor ??
                maxCtr.maxPlayerConfig.theme?.backgroundColor ??
                Colors.black,
            child: Builder(
              // Replaces inner GetBuilder(id: 'errorState') - actually external builder rebuilds everything so fine
              builder: (context) {
                /// Check if has any error
                if (maxCtr.maxVideoState == MaxVideoState.error) {
                  return widget.onVideoError?.call() ?? _videoErrorWidget;
                }

                return AspectRatio(
                  aspectRatio: _frameAspectRatio,
                  child: maxCtr.videoCtr?.value.isInitialized ?? false
                      ? _buildPlayer()
                      : Center(child: circularProgressIndicator),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return widget.onLoading?.call(context) ??
        const CircularProgressIndicator(
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2,
        );
  }

  Widget _thumbnailAndLoadingWidget() {
    if (widget.videoThumbnail == null) {
      return _buildLoading();
    }

    return SizedBox.expand(
      child: TweenAnimationBuilder<double>(
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: child,
        ),
        tween: Tween<double>(begin: 0.2, end: 0.7),
        duration: const Duration(milliseconds: 400),
        child: DecoratedBox(
          decoration: BoxDecoration(image: widget.videoThumbnail),
          child: Center(
            child: _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final _videoAspectRatio = widget.matchVideoAspectRatioToFrame
        ? maxCtr.videoCtr?.value.aspectRatio ?? widget.videoAspectRatio
        : widget.videoAspectRatio;
    return _MaxCoreVideoPlayer(
      videoPlayerCtr: maxCtr.videoCtr!,
      videoAspectRatio: _videoAspectRatio,
      tag: widget.controller.getTag,
      controller: maxCtr,
    );
  }
}
