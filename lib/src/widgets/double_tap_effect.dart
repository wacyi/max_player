import 'dart:async';

import 'package:flutter/material.dart';

class DoubleTapRippleEffect extends StatefulWidget {
  const DoubleTapRippleEffect({
    super.key,
    this.child,
    this.wrapper,
    this.rippleColor,
    this.backgroundColor,
    this.borderRadius,
    this.rippleDuration,
    this.rippleEndingDuraiton,
    this.onDoubleTap,
    this.width,
    this.height,
  });

  /// child widget [child]
  final Widget? child;

  /// Helps to wrap child widget inside a parent widget
  final Widget Function(
    Widget parentWidget,
    double curveRadius,
  )? wrapper;

  /// touch effect color of widget [rippleColor]
  final Color? rippleColor;

  /// TouchRippleEffect widget background color [backgroundColor]
  final Color? backgroundColor;

  /// if you have border of child widget then you should
  /// apply [borderRadius]
  final BorderRadius? borderRadius;

  /// animation duration of touch effect. [rippleDuration]
  final Duration? rippleDuration;

  /// duration to stay the frame. [rippleEndingDuraiton]
  final Duration? rippleEndingDuraiton;

  /// user click or tap handle [onDoubleTap].
  final VoidCallback? onDoubleTap;

  /// TouchRippleEffect widget width size [width]
  final double? width;

  /// TouchRippleEffect widget height size [height]
  final double? height;

  @override
  State<DoubleTapRippleEffect> createState() =>
      _DoubleTapRippleEffectState();
}

class _DoubleTapRippleEffectState
    extends State<DoubleTapRippleEffect>
    with SingleTickerProviderStateMixin {
  // by default offset will be 0,0
  // it will be set when user tap on widget
  Offset _tapOffset = Offset.zero;

  // globalKey variable decleared
  final GlobalKey _globalKey = GlobalKey();

  // animation global variable decleared and
  // type cast is double
  late Animation<double> _anim;

  // animation controller global variable decleared
  late AnimationController _animationController;

  /// width of user child widget
  double _mWidth = 0;

  // height of user child widget
  double _mHeight = 0;

  // tween animation global variable decleared and
  // type cast is double
  late Tween<double> _tweenAnim;

  // animation count of Tween anim.
  // by default value is 0.
  double _animRadiusValue = 0;

  @override
  void initState() {
    super.initState();
    // animation controller initialized
    _animationController = AnimationController(
      vsync: this,
      duration: widget.rippleDuration ??
          const Duration(milliseconds: 300),
    );
    // animation controller listener added
    _animationController.addListener(_update);
  }

  // update animation when started
  void _update() {
    setState(() {
      _animRadiusValue = _anim.value;
    });
    // animation status function calling
    _animStatus();
  }

  // checking animation status is completed
  void _animStatus() {
    if (_anim.status == AnimationStatus.completed) {
      unawaited(Future<void>.delayed(
        widget.rippleEndingDuraiton ??
            const Duration(milliseconds: 600),
      ).then((value) {
        setState(() {
          _animRadiusValue = 0;
        });
        // stoping animation after completed
        _animationController.stop();
      }),);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // animation initialize reset and start
  void _animate() {
    final width = widget.width ?? _mWidth;
    final height = widget.height ?? _mHeight;
    _tweenAnim =
        Tween(begin: 0, end: (width + height) / 1.5);
    _anim = _tweenAnim.animate(_animationController);

    _animationController.reset();
    unawaited(_animationController.forward());
  }

  @override
  Widget build(BuildContext context) {
    final curveRadius = (_mWidth + _mHeight) / 2;
    if (widget.wrapper != null) {
      return widget.wrapper!(_builder(), curveRadius);
    }
    return _builder();
  }

  Widget _builder() {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      onDoubleTapDown: (details) {
        // getting tap [localPostion] of user
        final lp = details.localPosition;
        setState(() {
          _tapOffset = Offset(lp.dx, lp.dy);
        });

        // getting [size] of child widget
        final size =
            _globalKey.currentContext!.size!;

        _mWidth = size.width;
        _mHeight = size.height;

        // starting animation
        _animate();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        key: _globalKey,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        child: Stack(
          children: [
            widget.child!,
            Opacity(
              opacity: 0.3,
              child: CustomPaint(
                painter: RipplePainer(
                  offset: _tapOffset,
                  circleRadius: _animRadiusValue,
                  fillColor: widget.rippleColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RipplePainer extends CustomPainter {
  RipplePainer({
    this.offset,
    this.circleRadius,
    this.fillColor,
  });

  // user tap locations [Offset]
  final Offset? offset;

  // radius of circle which will be ripple color size
  final double? circleRadius;

  // fill color of ripple [fillColor]
  final Color? fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillColor == null) {
      throw Exception(
        'rippleColor of TouchRippleEffect == null',
      );
    }
    final paint = Paint()
      ..color = fillColor!
      ..isAntiAlias = true;

    canvas.drawCircle(
      offset!,
      circleRadius!,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
