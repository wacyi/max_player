part of 'max_video_controller.dart';

class _MaxGesturesController extends _MaxVideoQualityController {
  Timer? leftDoubleTapTimer;
  Timer? rightDoubleTapTimer;
  int leftDoubleTapduration = 0;
  int rightDubleTapduration = 0;
  bool isLeftDbTapIconVisible = false;
  bool isRightDbTapIconVisible = false;

  Timer? hoverOverlayTimer;

  /// Handle left double tap (seek backward).
  void onLeftDoubleTap({int? seconds}) {
    isShowOverlay(true);
    leftDoubleTapTimer?.cancel();
    rightDoubleTapTimer?.cancel();

    isRightDbTapIconVisible = false;
    isLeftDbTapIconVisible = true;
    updateLeftTapDuration(
      leftDoubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    unawaited(
      seekBackward(
        Duration(seconds: seconds ?? doubleTapForwardSeconds),
      ),
    );
    update(['double-tap-left']);
    leftDoubleTapTimer = Timer(const Duration(milliseconds: 500), () {
      isLeftDbTapIconVisible = false;
      updateLeftTapDuration(0);
      leftDoubleTapTimer?.cancel();
      if (isvideoPlaying) {
        unawaited(playVideo(play: true));
      }
      isShowOverlay(false);
    });
  }

  /// Handle right double tap (seek forward).
  void onRightDoubleTap({int? seconds}) {
    isShowOverlay(true);
    rightDoubleTapTimer?.cancel();
    leftDoubleTapTimer?.cancel();

    isLeftDbTapIconVisible = false;
    isRightDbTapIconVisible = true;
    updateRightTapDuration(
      rightDubleTapduration += seconds ?? doubleTapForwardSeconds,
    );
    unawaited(
      seekForward(
        Duration(seconds: seconds ?? doubleTapForwardSeconds),
      ),
    );
    update(['double-tap-right']);
    rightDoubleTapTimer = Timer(const Duration(milliseconds: 500), () {
      isRightDbTapIconVisible = false;
      updateRightTapDuration(0);
      rightDoubleTapTimer?.cancel();
      if (isvideoPlaying) {
        unawaited(playVideo(play: true));
      }
      isShowOverlay(false);
    });
  }

  /// Update left double tap duration.
  void updateLeftTapDuration(int val) {
    leftDoubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }

  /// Update right double tap duration.
  void updateRightTapDuration(int val) {
    rightDubleTapduration = val;
    update(['double-tap']);
    update(['update-all']);
  }
}
