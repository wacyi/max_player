part of 'package:max_player/src/max_player.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;
  final MaxVideoController controller;

  const _VideoOverlays({Key? key, required this.tag, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    if (maxCtr.overlayBuilder != null) {
      return ListenableBuilder(
        listenable: maxCtr,
        builder: (context, _) {
          ///Custom overlay
          final progressBar = MaxProgressBar(
            tag: tag,
            maxProgressBarConfig: maxCtr.maxProgressBarConfig,
            controller: maxCtr,
          );
          final overlayOptions = OverLayOptions(
            maxVideoState: maxCtr.maxVideoState,
            videoDuration: maxCtr.videoDuration,
            videoPosition: maxCtr.videoPosition,
            isFullScreen: maxCtr.isFullScreen,
            isLooping: maxCtr.isLooping,
            isOverlayVisible: maxCtr.isOverlayVisible,
            isMute: maxCtr.isMute,
            autoPlay: maxCtr.autoPlay,
            currentVideoPlaybackSpeed: maxCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: maxCtr.videoPlaybackSpeeds,
            videoPlayerType: maxCtr.videoPlayerType,
            maxProgresssBar: progressBar,
            // podProgresssBar removed as it is not defined/needed
          );

          /// Returns the custom overlay, otherwise returns the default
          /// overlay with gesture detector
          return maxCtr.overlayBuilder!(overlayOptions);
        },
      );
    } else {
      ///Built in overlay
      return ListenableBuilder(
        listenable: maxCtr,
        builder: (context, _) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: maxCtr.isOverlayVisible ? 1 : 0,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                _MobileOverlay(tag: tag, controller: maxCtr),
              ],
            ),
          );
        },
      );
    }
  }
}
