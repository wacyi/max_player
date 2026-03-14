import 'dart:async';

import 'package:flutter/material.dart';
import 'package:max_player/src/controllers/max_video_controller.dart';
import 'package:max_player/src/models/max_player_theme.dart';
import 'package:max_player/src/models/max_progress_bar_config.dart';
import 'package:video_player/video_player.dart';

/// Renders progress bar for the video using custom paint.
class MaxProgressBar extends StatefulWidget {
  const MaxProgressBar({
    required this.tag,
    required this.controller,
    super.key,
    MaxProgressBarConfig? maxProgressBarConfig,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.alignment = Alignment.center,
  }) : maxProgressBarConfig =
            maxProgressBarConfig ??
            const MaxProgressBarConfig();

  final MaxProgressBarConfig maxProgressBarConfig;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDragUpdate;
  final Alignment alignment;
  final String tag;
  final MaxVideoController controller;

  @override
  State<MaxProgressBar> createState() =>
      _MaxProgressBarState();
}

class _MaxProgressBarState extends State<MaxProgressBar> {
  late final MaxVideoController maxCtr =
      widget.controller;
  late VideoPlayerValue? videoPlayerValue =
      maxCtr.videoCtr?.value;
  bool _controllerWasPlaying = false;

  void seekToRelativePosition(Offset globalPosition) {
    final box =
        context.findRenderObject() as RenderBox?;
    if (box != null) {
      final tapPos =
          box.globalToLocal(globalPosition);
      final relative = tapPos.dx / box.size.width;
      final position =
          (videoPlayerValue?.duration ??
              Duration.zero) *
          relative;
      unawaited(maxCtr.seekTo(position));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerValue == null) {
      return const SizedBox();
    }

    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) {
        videoPlayerValue = maxCtr.videoCtr?.value;
        return LayoutBuilder(
          builder: (context, size) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: _progressBar(size),
              onHorizontalDragStart:
                  (details) {
                if (!videoPlayerValue!
                    .isInitialized) {
                  return;
                }
                _controllerWasPlaying =
                    maxCtr.videoCtr?.value
                        .isPlaying ??
                    false;
                if (_controllerWasPlaying) {
                  unawaited(
                    maxCtr.videoCtr?.pause(),
                  );
                }

                if (widget.onDragStart != null) {
                  widget.onDragStart?.call();
                }
              },
              onHorizontalDragUpdate:
                  (details) {
                if (!videoPlayerValue!
                    .isInitialized) {
                  return;
                }
                maxCtr.isShowOverlay(true);
                seekToRelativePosition(
                  details.globalPosition,
                );

                widget.onDragUpdate?.call();
              },
              onHorizontalDragEnd:
                  (details) {
                if (_controllerWasPlaying) {
                  unawaited(
                    maxCtr.videoCtr?.play(),
                  );
                }
                maxCtr.toggleVideoOverlay();

                if (widget.onDragEnd != null) {
                  widget.onDragEnd?.call();
                }
              },
              onTapDown: (details) {
                if (!videoPlayerValue!
                    .isInitialized) {
                  return;
                }
                seekToRelativePosition(
                  details.globalPosition,
                );
              },
            );
          },
        );
      },
    );
  }

  MouseRegion _progressBar(BoxConstraints size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding:
            widget.maxProgressBarConfig.padding,
        child: SizedBox(
          width: size.maxWidth,
          height: widget.maxProgressBarConfig
              .circleHandlerRadius,
          child: Align(
            alignment: widget.alignment,
            child: ListenableBuilder(
              listenable: maxCtr,
              builder: (context, _) => CustomPaint(
                painter: _ProgressBarPainter(
                  videoPlayerValue!,
                  maxProgressBarConfig: widget
                      .maxProgressBarConfig
                      .copyWith(
                    circleHandlerRadius: maxCtr
                                .isOverlayVisible ||
                            widget
                                .maxProgressBarConfig
                                .alwaysVisibleCircleHandler
                        ? widget
                            .maxProgressBarConfig
                            .circleHandlerRadius
                        : 0,
                  ),
                  theme: maxCtr
                      .maxPlayerConfig.theme,
                ),
                size: Size(
                  double.maxFinite,
                  widget
                      .maxProgressBarConfig.height,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(
    this.value, {
    this.maxProgressBarConfig,
    this.theme,
  });

  VideoPlayerValue value;
  MaxProgressBarConfig? maxProgressBarConfig;
  MaxPlayerTheme? theme;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final height = maxProgressBarConfig!.height;
    final width = size.width;
    final curveRadius =
        maxProgressBarConfig!.curveRadius;
    final circleHandlerRadius =
        maxProgressBarConfig!.circleHandlerRadius;
    final backgroundPaint =
        maxProgressBarConfig!.getBackgroundPaint !=
                null
            ? maxProgressBarConfig!
                .getBackgroundPaint!(
                width: width,
                height: height,
                circleHandlerRadius:
                    circleHandlerRadius,
              )
            : (Paint()
              ..color = maxProgressBarConfig!
                      .backgroundColor ??
                  theme?.backgroundColor ??
                  const Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.24,
                  ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(width, height),
        ),
        Radius.circular(curveRadius),
      ),
      backgroundPaint,
    );
    if (!value.isInitialized) {
      return;
    }

    final playedPartPercent =
        value.position.inMilliseconds /
            value.duration.inMilliseconds;
    final playedPart = playedPartPercent > 1
        ? width
        : playedPartPercent * width;

    for (final range in value.buffered) {
      final start =
          range.startFraction(value.duration) *
              width;
      final end =
          range.endFraction(value.duration) *
              width;

      final bufferedPaint =
          maxProgressBarConfig!.getBufferedPaint !=
                  null
              ? maxProgressBarConfig!
                  .getBufferedPaint!(
                  width: width,
                  height: height,
                  playedPart: playedPart,
                  circleHandlerRadius:
                      circleHandlerRadius,
                  bufferedStart: start,
                  bufferedEnd: end,
                )
              : (Paint()
                ..color = maxProgressBarConfig!
                        .bufferedBarColor ??
                    theme?.bufferedBarColor ??
                    const Color.fromRGBO(
                      255,
                      255,
                      255,
                      0.38,
                    ));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, 0),
            Offset(end, height),
          ),
          Radius.circular(curveRadius),
        ),
        bufferedPaint,
      );
    }

    final playedPaint =
        maxProgressBarConfig!.getPlayedPaint != null
            ? maxProgressBarConfig!.getPlayedPaint!(
                width: width,
                height: height,
                playedPart: playedPart,
                circleHandlerRadius:
                    circleHandlerRadius,
              )
            : (Paint()
              ..color = maxProgressBarConfig!
                      .playingBarColor ??
                  theme?.playingBarColor ??
                  Colors.red);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(playedPart, height),
        ),
        Radius.circular(curveRadius),
      ),
      playedPaint,
    );

    final handlePaint = maxProgressBarConfig!
                .getCircleHandlerPaint !=
            null
        ? maxProgressBarConfig!
            .getCircleHandlerPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            circleHandlerRadius:
                circleHandlerRadius,
          )
        : (Paint()
          ..color = maxProgressBarConfig!
                  .circleHandlerColor ??
              theme?.circleHandlerColor ??
              Colors.red);

    canvas.drawCircle(
      Offset(playedPart, height / 2),
      circleHandlerRadius,
      handlePaint,
    );
  }
}
