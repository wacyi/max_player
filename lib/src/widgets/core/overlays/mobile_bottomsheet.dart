part of 'package:max_player/src/max_player.dart';

class _MobileBottomSheet extends StatelessWidget {
  const _MobileBottomSheet({
    required this.tag,
    required this.controller,
  });

  final String tag;
  final MaxVideoController controller;

  void showMobileBottomSheet(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => _MobileBottomSheet(
          tag: tag,
          controller: controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (maxCtr.vimeoOrVideoUrls.isNotEmpty)
            _bottomSheetTiles(
              title: maxCtr.maxPlayerLabels.quality,
              icon: Icons.video_settings_rounded,
              subText:
                  '${maxCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(
                  const Duration(milliseconds: 100),
                  () {
                    unawaited(
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (context) => SafeArea(
                          child:
                              _VideoQualitySelectorMob(
                            tag: tag,
                            onTap: null,
                            controller: maxCtr,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          _bottomSheetTiles(
            title: maxCtr.maxPlayerLabels.loopVideo,
            icon: Icons.loop_rounded,
            subText: maxCtr.isLooping
                ? maxCtr.maxPlayerLabels.optionEnabled
                : maxCtr.maxPlayerLabels.optionDisabled,
            onTap: () {
              Navigator.of(context).pop();
              unawaited(maxCtr.toggleLooping());
            },
          ),
          _bottomSheetTiles(
            title:
                maxCtr.maxPlayerLabels.playbackSpeed,
            icon: Icons.slow_motion_video_rounded,
            subText: maxCtr.currentPaybackSpeed,
            onTap: () {
              Navigator.of(context).pop();
              Timer(
                const Duration(milliseconds: 100),
                () {
                  unawaited(
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SafeArea(
                        child:
                            _VideoPlaybackSelectorMob(
                          tag: tag,
                          onTap: null,
                          controller: maxCtr,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(title),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              const SizedBox(
                height: 4,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoQualitySelectorMob extends StatelessWidget {
  const _VideoQualitySelectorMob({
    required this.onTap,
    required this.tag,
    required this.controller,
  });

  final VoidCallback? onTap;
  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: maxCtr.vimeoOrVideoUrls
            .map(
              (e) => ListTile(
                title: Text('${e.quality}p'),
                onTap: () {
                  if (onTap != null) {
                    onTap!();
                  } else {
                    Navigator.of(context).pop();
                  }
                  unawaited(
                    maxCtr.changeVideoQuality(e.quality),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _VideoPlaybackSelectorMob extends StatelessWidget {
  const _VideoPlaybackSelectorMob({
    required this.onTap,
    required this.tag,
    required this.controller,
  });

  final VoidCallback? onTap;
  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: maxCtr.maxPlayerConfig.availableSpeeds
            .map(
              (speed) => ListTile(
                title: Text('${speed}x'),
                onTap: () {
                  if (onTap != null) {
                    onTap!();
                  } else {
                    Navigator.of(context).pop();
                  }
                  unawaited(
                    maxCtr.setVideoPlayBack('${speed}x'),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MobileOverlayBottomControlles extends StatelessWidget {
  const _MobileOverlayBottomControlles({
    required this.tag,
    required this.controller,
  });

  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    const durationTextStyle = TextStyle(
      color: Colors.white70,
      fontSize: 12,
    );
    const itemColor = Colors.white;

    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) => maxCtr.isOverlayVisible ||
              !maxCtr.alwaysShowProgressBar
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                MaxProgressBar(
                  tag: tag,
                  maxProgressBarConfig:
                      maxCtr.maxProgressBarConfig,
                  controller: maxCtr,
                ),
                // Bottom row: time, spacer, controls
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      if (maxCtr.isFullScreen)
                        MaterialIconButton(
                          toolTipMesg: maxCtr.isMute
                              ? maxCtr
                                  .maxPlayerLabels.unmute
                              : maxCtr
                                  .maxPlayerLabels.mute,
                          color: itemColor,
                          onPressed: maxCtr.toggleMute,
                          child: Icon(
                            maxCtr.isMute
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: itemColor,
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        maxCtr.calculateVideoDuration(
                          maxCtr.videoPosition,
                        ),
                        style: durationTextStyle,
                      ),
                      const Text(
                        ' / ',
                        style: durationTextStyle,
                      ),
                      Text(
                        maxCtr.calculateVideoDuration(
                          maxCtr.videoDuration,
                        ),
                        style: durationTextStyle,
                      ),
                      const Spacer(),
                      MaterialIconButton(
                        toolTipMesg: maxCtr.isFullScreen
                            ? maxCtr.maxPlayerLabels
                                .exitFullScreen
                            : maxCtr.maxPlayerLabels
                                .fullscreen,
                        color: itemColor,
                        onPressed: () {
                          if (maxCtr.isFullScreen) {
                            unawaited(
                              maxCtr.disableFullScreen(
                                context,
                                tag,
                              ),
                            );
                          } else {
                            unawaited(
                              maxCtr.enableFullScreen(tag),
                            );
                          }
                        },
                        child: Icon(
                          maxCtr.isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: itemColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}
