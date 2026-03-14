part of 'package:max_player/src/max_player.dart';

class FullScreenView extends StatefulWidget {
  const FullScreenView({
    required this.tag,
    required this.controller,
    super.key,
  });

  final String tag;
  final MaxVideoController controller;

  @override
  State<FullScreenView> createState() =>
      _FullScreenViewState();
}

class _FullScreenViewState
    extends State<FullScreenView>
    with TickerProviderStateMixin {
  late MaxVideoController maxCtr;

  @override
  void initState() {
    maxCtr = widget.controller;
    maxCtr.fullScreenContext = context;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = maxCtr.maxPlayerConfig.theme;
    final loadingWidget =
        maxCtr.onLoading?.call(context) ??
            CircularProgressIndicator(
              backgroundColor:
                  theme?.backgroundColor ??
                      Colors.black87,
              color: theme?.iconColor ??
                  Colors.white,
              strokeWidth: 2,
            );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) async {
        if (didPop) return;
        await maxCtr.disableFullScreen(
          context,
          widget.tag,
        );
      },
      child: Scaffold(
        backgroundColor:
            theme?.backgroundColor ??
                Colors.black,
        body: ListenableBuilder(
          listenable: maxCtr,
          builder: (context, _) => Center(
            child: ColoredBox(
              color: theme?.backgroundColor ??
                  Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height,
                width: MediaQuery.of(context)
                    .size
                    .width,
                child: Center(
                  child: maxCtr.videoCtr == null
                      ? loadingWidget
                      : maxCtr.videoCtr!.value
                              .isInitialized
                          ? _MaxCoreVideoPlayer(
                              tag: widget.tag,
                              videoPlayerCtr:
                                  maxCtr
                                      .videoCtr!,
                              videoAspectRatio: maxCtr
                                      .videoCtr
                                      ?.value
                                      .aspectRatio ??
                                  16 / 9,
                              controller: maxCtr,
                            )
                          : loadingWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
