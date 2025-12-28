part of 'package:max_player/src/max_player.dart';

class _MobileOverlay extends StatelessWidget {
  final String tag;
  final MaxVideoController controller;

  const _MobileOverlay({
    Key? key,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    const overlayColor = Colors.black38;
    final itemColor = maxCtr.maxPlayerConfig.theme?.iconColor ?? Colors.white;
    return Stack(
      alignment: Alignment.center,
      children: [
        _VideoGestureDetector(
          tag: tag,
          controller: maxCtr, // Pass controller
          child: ColoredBox(
            color: overlayColor,
            child: Row(
              children: [
                Expanded(
                  child: DoubleTapIcon(
                    tag: tag,
                    isForward: false,
                    height: double.maxFinite,
                    onDoubleTap: _isRtl()
                        ? maxCtr.onRightDoubleTap
                        : maxCtr.onLeftDoubleTap,
                    controller: maxCtr, // Pass controller
                  ),
                ),
                SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: _AnimatedPlayPauseIcon(
                        tag: tag,
                        size: 42,
                        controller: maxCtr), // Pass controller
                  ),
                ),
                Expanded(
                  child: DoubleTapIcon(
                    isForward: true,
                    tag: tag,
                    height: double.maxFinite,
                    onDoubleTap: _isRtl()
                        ? maxCtr.onLeftDoubleTap
                        : maxCtr.onRightDoubleTap,
                    controller: maxCtr, // Pass controller
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: IgnorePointer(
                  child: maxCtr.videoTitle ?? const SizedBox(),
                ),
              ),
              MaterialIconButton(
                toolTipMesg: maxCtr.maxPlayerLabels.settings,
                color: itemColor,
                onPressed: () {
                  if (maxCtr.isOverlayVisible) {
                    _bottomSheet(context);
                  } else {
                    maxCtr.toggleVideoOverlay();
                  }
                },
                child: const Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _MobileOverlayBottomControlles(
              tag: tag, controller: maxCtr), // Pass controller
        ),
      ],
    );
  }

  bool _isRtl() {
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    final langs = [
      'ar', // Arabic
      'fa', // Farsi
      'he', // Hebrew
      'ps', // Pashto
      'ur', // Urdu
    ];
    for (int i = 0; i < langs.length; i++) {
      final lang = langs[i];
      if (locale.toString().contains(lang)) {
        return true;
      }
    }
    return false;
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
          child: _MobileBottomSheet(
              tag: tag, controller: controller)), // Pass controller
    );
  }
}
