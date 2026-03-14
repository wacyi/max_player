import 'dart:developer';

import 'package:max_player/max_player.dart';

void maxLog(String message) =>
    MaxVideoPlayer.enableLogs
        ? log(message, name: 'max')
        : null;
