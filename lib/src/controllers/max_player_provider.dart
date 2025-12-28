import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'max_video_controller.dart';

final maxVideoControllerProvider =
    ChangeNotifierProvider.family<MaxVideoController, String>((ref, id) {
  return MaxVideoController();
});
