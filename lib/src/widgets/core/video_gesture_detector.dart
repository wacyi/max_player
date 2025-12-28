part of 'package:max_player/src/max_player.dart';

class _VideoGestureDetector extends StatelessWidget {
  final Widget? child;
  final String tag;
  final MaxVideoController controller;

  const _VideoGestureDetector({
    Key? key,
    this.child,
    required this.tag,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = controller;
    return GestureDetector(
      onTap: maxCtr.toggleVideoOverlay,
      child: child,
    );
  }
}
