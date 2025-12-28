part of 'package:max_player/src/max_player.dart';

class _MaxCoreVideoPlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  final double videoAspectRatio;
  final String tag;
  final MaxVideoController controller;

  const _MaxCoreVideoPlayer({
    Key? key,
    required this.videoPlayerCtr,
    required this.videoAspectRatio,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return Builder(
      builder: (ctrx) {
        return KeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKeyEvent: (value) => maxCtr.onKeyBoardEvents(
            event: value,
            appContext: ctrx,
            tag: tag,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: VideoPlayer(videoPlayerCtr),
                ),
              ),
              ListenableBuilder(
                listenable: maxCtr,
                builder: (context, _) {
                  if (maxCtr.videoThumbnail == null) {
                    return const SizedBox();
                  }

                  if (maxCtr.maxVideoState == MaxVideoState.paused &&
                      maxCtr.videoPosition == Duration.zero) {
                    return SizedBox.expand(
                      child: TweenAnimationBuilder<double>(
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: child,
                        ),
                        tween: Tween<double>(begin: 0.7, end: 1),
                        duration: const Duration(milliseconds: 400),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: maxCtr.videoThumbnail,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              _VideoOverlays(tag: tag, controller: maxCtr),
              IgnorePointer(
                child: ListenableBuilder(
                  listenable: maxCtr,
                  builder: (context, _) {
                    final loadingWidget = maxCtr.onLoading?.call(context) ??
                        const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );

                    if (maxCtr.maxVideoState == MaxVideoState.loading) {
                      return loadingWidget;
                    }
                    return const SizedBox();
                  },
                ),
              ),
              ListenableBuilder(
                listenable: maxCtr,
                builder: (context, _) => maxCtr.isFullScreen
                    ? const SizedBox()
                    : (maxCtr.isOverlayVisible || !maxCtr.alwaysShowProgressBar
                        ? const SizedBox()
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: MaxProgressBar(
                              tag: tag,
                              alignment: Alignment.bottomCenter,
                              maxProgressBarConfig: maxCtr.maxProgressBarConfig,
                              controller: maxCtr,
                            ),
                          )),
              ),
            ],
          ),
        );
      },
    );
  }
}
