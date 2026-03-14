part of 'package:max_player/src/max_player.dart';

class _MobileOverlay extends StatelessWidget {
  const _MobileOverlay({
    required this.tag,
    required this.controller,
  });

  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    final itemColor =
        maxCtr.maxPlayerConfig.theme?.iconColor ?? Colors.white;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Tap to toggle overlay + double-tap zones
        _VideoGestureDetector(
          tag: tag,
          controller: maxCtr,
          child: Row(
            children: [
              // Left double-tap zone (seek backward)
              Expanded(
                child: DoubleTapIcon(
                  tag: tag,
                  isForward: false,
                  height: double.maxFinite,
                  onDoubleTap: _isRtl()
                      ? maxCtr.onRightDoubleTap
                      : maxCtr.onLeftDoubleTap,
                  controller: maxCtr,
                ),
              ),
              // Center gap for play/pause
              const SizedBox(width: 80),
              // Right double-tap zone (seek forward)
              Expanded(
                child: DoubleTapIcon(
                  isForward: true,
                  tag: tag,
                  height: double.maxFinite,
                  onDoubleTap: _isRtl()
                      ? maxCtr.onLeftDoubleTap
                      : maxCtr.onRightDoubleTap,
                  controller: maxCtr,
                ),
              ),
            ],
          ),
        ),

        // Top gradient + title & settings
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(
              top: 4,
              left: 4,
              right: 4,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: IgnorePointer(
                    child: maxCtr.videoTitle ??
                        const SizedBox(),
                  ),
                ),
                MaterialIconButton(
                  toolTipMesg:
                      maxCtr.maxPlayerLabels.settings,
                  color: itemColor,
                  onPressed: () {
                    if (maxCtr.isOverlayVisible) {
                      _bottomSheet(context);
                    } else {
                      maxCtr.toggleVideoOverlay();
                    }
                  },
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: itemColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center play/pause button
        Center(
          child: _AnimatedPlayPauseIcon(
            tag: tag,
            size: 46,
            controller: maxCtr,
          ),
        ),

        // Bottom gradient + controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ],
              ),
            ),
            child: _MobileOverlayBottomControlles(
              tag: tag,
              controller: maxCtr,
            ),
          ),
        ),
      ],
    );
  }

  bool _isRtl() {
    final locale = WidgetsBinding
        .instance.platformDispatcher.locale;
    final langs = ['ar', 'fa', 'he', 'ps', 'ur'];
    for (final lang in langs) {
      if (locale.toString().contains(lang)) {
        return true;
      }
    }
    return false;
  }

  void _bottomSheet(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: _MobileBottomSheet(
            tag: tag,
            controller: controller,
          ),
        ),
      ),
    );
  }
}
