part of 'package:max_player/src/max_player.dart';

class _VideoGestureDetector extends StatelessWidget {
  const _VideoGestureDetector({
    required this.tag,
    required this.controller,
    this.child,
  });

  final Widget? child;
  final String tag;
  final MaxVideoController controller;

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return GestureDetector(
      onTap: maxCtr.toggleVideoOverlay,
      child: child,
    );
  }
}
