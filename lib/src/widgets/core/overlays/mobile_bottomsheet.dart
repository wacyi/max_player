part of 'package:max_player/src/max_player.dart';

class _MobileBottomSheet extends StatelessWidget {
  final String tag;
  final MaxVideoController controller;

  const _MobileBottomSheet({
    Key? key,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  void showMobileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _MobileBottomSheet(tag: tag, controller: controller),
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
              subText: '${maxCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: _VideoQualitySelectorMob(
                        tag: tag,
                        onTap: null,
                        controller: maxCtr,
                      ),
                    ),
                  );
                });
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
              maxCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
            title: maxCtr.maxPlayerLabels.playbackSpeed,
            icon: Icons.slow_motion_video_rounded,
            subText: maxCtr.currentPaybackSpeed,
            onTap: () {
              Navigator.of(context).pop();
              Timer(const Duration(milliseconds: 100), () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SafeArea(
                    child: _VideoPlaybackSelectorMob(
                      tag: tag,
                      onTap: null,
                      controller: maxCtr,
                    ),
                  ),
                );
              });
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
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
            ),
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
  final void Function()? onTap;
  final String tag;
  final MaxVideoController controller;

  const _VideoQualitySelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
    required this.controller,
  }) : super(key: key);

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
                  onTap != null ? onTap!() : Navigator.of(context).pop();

                  maxCtr.changeVideoQuality(e.quality);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _VideoPlaybackSelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;
  final MaxVideoController controller;

  const _VideoPlaybackSelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: maxCtr.videoPlaybackSpeeds
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();
                  maxCtr.setVideoPlayBack(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MobileOverlayBottomControlles extends StatelessWidget {
  final String tag;
  final MaxVideoController controller;

  const _MobileOverlayBottomControlles({
    Key? key,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) => maxCtr.isOverlayVisible ||
              !maxCtr.alwaysShowProgressBar
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (maxCtr.videoTitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: maxCtr.videoTitle,
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    if (maxCtr.isFullScreen)
                      MaterialIconButton(
                        toolTipMesg: maxCtr.isMute
                            ? maxCtr.maxPlayerLabels.unmute ?? 'Unmute'
                            : maxCtr.maxPlayerLabels.mute ?? 'Mute',
                        color: itemColor,
                        onPressed: maxCtr.toggleMute,
                        child: Icon(
                          maxCtr.isMute
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: itemColor,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Text(
                      maxCtr.calculateVideoDuration(maxCtr.videoPosition),
                      style: durationTextStyle,
                    ),
                    const Text(
                      ' / ',
                      style: durationTextStyle,
                    ),
                    Text(
                      maxCtr.calculateVideoDuration(maxCtr.videoDuration),
                      style: durationTextStyle,
                    ),
                    const Spacer(),
                    MaterialIconButton(
                      toolTipMesg: maxCtr.isFullScreen
                          ? maxCtr.maxPlayerLabels.exitFullScreen ??
                              'Exit full screen'
                          : maxCtr.maxPlayerLabels.fullscreen ?? 'Fullscreen',
                      color: itemColor,
                      onPressed: () {
                        if (maxCtr.isFullScreen) {
                          maxCtr.disableFullScreen(context, tag);
                        } else {
                          maxCtr.enableFullScreen(tag);
                        }
                      },
                      child: Icon(
                        maxCtr.isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: itemColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                MaxProgressBar(
                  tag: tag,
                  maxProgressBarConfig: maxCtr.maxProgressBarConfig,
                  controller: maxCtr,
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}
