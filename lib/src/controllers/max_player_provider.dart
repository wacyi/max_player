import 'package:flutter_riverpod/legacy.dart'
    show ChangeNotifierProvider;
import 'package:max_player/src/controllers/max_video_controller.dart';

// Type is inferred from ChangeNotifierProvider.family.
// ignore: specify_nonobvious_property_types
final maxVideoControllerProvider =
    ChangeNotifierProvider
        .family<MaxVideoController, String>(
  (ref, id) {
    return MaxVideoController();
  },
);
