import 'dart:async';

import 'package:flutter/material.dart';
import 'package:max_player/src/controllers/max_video_controller.dart';
import 'package:max_player/src/widgets/double_tap_effect.dart';

class DoubleTapIcon extends StatefulWidget {
  const DoubleTapIcon({
    required this.onDoubleTap,
    required this.tag,
    required this.isForward,
    required this.controller,
    super.key,
    this.iconOnly = false,
    this.height = 50,
    this.width,
  });

  final VoidCallback onDoubleTap;
  final String tag;
  final bool iconOnly;
  final bool isForward;
  final double height;
  final double? width;
  final MaxVideoController controller;

  @override
  State<DoubleTapIcon> createState() => _DoubleTapIconState();
}

class _DoubleTapIconState extends State<DoubleTapIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> opacityCtr;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    opacityCtr = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    widget.controller
        .addListener(_onMaxCtrChange);
  }

  void _onMaxCtrChange() {
    // Listener for controller changes to trigger
    // double-tap animation when needed.
  }

  @override
  void dispose() {
    widget.controller
        .removeListener(_onMaxCtrChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    widget.onDoubleTap();
    unawaited(
      _animationController.forward().then((_) {
        unawaited(_animationController.reverse());
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.iconOnly) return iconWithText();
    return DoubleTapRippleEffect(
      onDoubleTap: _onDoubleTap,
      rippleColor: Colors.white,
      wrapper: (parentWidget, curveRadius) {
        final forwardRadius = !widget.isForward
            ? Radius.zero
            : Radius.circular(curveRadius);
        final backwardRadius = widget.isForward
            ? Radius.zero
            : Radius.circular(curveRadius);
        return ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: forwardRadius,
            topLeft: forwardRadius,
            bottomRight: backwardRadius,
            topRight: backwardRadius,
          ),
          child: parentWidget,
        );
      },
      child: iconWithText(),
    );
  }

  SizedBox iconWithText() {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          const icon = Icon(
            Icons.play_arrow_sharp,
            size: 32,
            color: Colors.white,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatedBox(
                  quarterTurns:
                      widget.isForward ? 0 : 2,
                  child: Stack(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        opacity: opacityCtr.value,
                        child: icon,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 20,
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          opacity: opacityCtr.value,
                          child: icon,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 40,
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(
                            milliseconds: 600,
                          ),
                          opacity: opacityCtr.value,
                          child: icon,
                        ),
                      ),
                    ],
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    final maxCtr =
                        widget.controller;
                    final tapDuration = maxCtr
                            .isLeftDbTapIconVisible
                        ? maxCtr
                            .leftDoubleTapduration
                        : maxCtr
                            .rightDubleTapduration;
                    if (widget.isForward &&
                        maxCtr
                            .isRightDbTapIconVisible) {
                      return AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        opacity:
                            opacityCtr.value,
                        child: Text(
                          '$tapDuration ${maxCtr.maxPlayerLabels.seconds}',
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    if (!widget.isForward &&
                        maxCtr
                            .isLeftDbTapIconVisible) {
                      return AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        opacity:
                            opacityCtr.value,
                        child: Text(
                          '$tapDuration ${maxCtr.maxPlayerLabels.seconds}',
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
