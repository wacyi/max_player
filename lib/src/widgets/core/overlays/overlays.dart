part of 'package:max_player/src/max_player.dart';

class _VideoOverlays extends StatelessWidget {
  const _VideoOverlays({
    required this.tag,
    required this.controller,
  });

  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    if (maxCtr.overlayBuilder != null) {
      return ListenableBuilder(
        listenable: maxCtr,
        builder: (context, _) {
          final progressBar = MaxProgressBar(
            tag: tag,
            maxProgressBarConfig:
                maxCtr.maxProgressBarConfig,
            controller: maxCtr,
          );
          final overlayOptions = OverLayOptions(
            maxVideoState:
                maxCtr.maxVideoState,
            videoDuration:
                maxCtr.videoDuration,
            videoPosition:
                maxCtr.videoPosition,
            isFullScreen: maxCtr.isFullScreen,
            isLooping: maxCtr.isLooping,
            isOverlayVisible:
                maxCtr.isOverlayVisible,
            isMute: maxCtr.isMute,
            autoPlay: maxCtr.autoPlay,
            currentVideoPlaybackSpeed:
                maxCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: maxCtr
                .maxPlayerConfig.availableSpeeds
                .map((s) => '${s}x')
                .toList(),
            videoPlayerType:
                maxCtr.videoPlayerType,
            maxProgresssBar: progressBar,
          );
          return maxCtr
              .overlayBuilder!(overlayOptions);
        },
      );
    } else {
      return ListenableBuilder(
        listenable: maxCtr,
        builder: (context, _) {
          return AnimatedOpacity(
            duration:
                const Duration(milliseconds: 200),
            opacity:
                maxCtr.isOverlayVisible ? 1 : 0,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                _MobileOverlay(
                  tag: tag,
                  controller: maxCtr,
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
