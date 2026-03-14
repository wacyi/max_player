part of 'max_video_controller.dart';

class _MaxUiController extends _MaxBaseController {
  bool alwaysShowProgressBar = true;
  MaxProgressBarConfig maxProgressBarConfig =
      const MaxProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget? videoTitle;
  DecorationImage? videoThumbnail;

  /// Callback when fullscreen mode changes.
  // ignore: avoid_positional_boolean_parameters - callback signature
  Future<void> Function(bool isFullScreen)?
      onToggleFullScreen;

  /// Builder for custom loading widget.
  WidgetBuilder? onLoading;

  /// Video player labels.
  MaxPlayerLabels maxPlayerLabels = const MaxPlayerLabels();
}
