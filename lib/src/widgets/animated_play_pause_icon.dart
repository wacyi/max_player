part of 'package:max_player/src/max_player.dart';

class _AnimatedPlayPauseIcon extends StatefulWidget {
  final double? size;
  final String tag;
  final MaxVideoController controller;

  const _AnimatedPlayPauseIcon({
    Key? key,
    this.size,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  State<_AnimatedPlayPauseIcon> createState() => _AnimatedPlayPauseIconState();
}

class _AnimatedPlayPauseIconState extends State<_AnimatedPlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _payCtr;
  late MaxVideoController maxCtr;
  @override
  void initState() {
    maxCtr = widget.controller;
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    maxCtr.addListener(playPauseListner);
    if (maxCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (maxCtr.maxVideoState == MaxVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (maxCtr.maxVideoState == MaxVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    maxCtr.removeListener(playPauseListner);
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: maxCtr,
      builder: (context, _) => MaterialIconButton(
        toolTipMesg: maxCtr.isvideoPlaying
            ? maxCtr.maxPlayerLabels.pause ?? 'Pause'
            : maxCtr.maxPlayerLabels.play ?? 'Play',
        onPressed: maxCtr.isOverlayVisible ? maxCtr.togglePlayPauseVideo : null,
        child: onStateChange(maxCtr),
      ),
    );
  }

  Widget onStateChange(MaxVideoController maxCtr) {
    if (maxCtr.maxVideoState == MaxVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(maxCtr);
    }
  }

  Widget _playPause(MaxVideoController maxCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: maxCtr.maxPlayerConfig.theme?.iconColor ?? Colors.white,
      size: widget.size,
    );
  }
}
