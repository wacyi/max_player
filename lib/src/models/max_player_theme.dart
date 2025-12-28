import 'package:flutter/material.dart';

class MaxPlayerTheme {
  /// Primary color, used for key elements if not overridden.
  final Color? primaryColor;

  /// Secondary color.
  final Color? accentColor;

  /// Main background color.
  final Color? backgroundColor;

  /// Color for icons (play/pause, volume, etc.).
  /// Defaults to [Colors.white] if not provided.
  final Color? iconColor;

  /// Color for the portion of the progress bar that has been played.
  /// Defaults to [Colors.red] if not provided.
  final Color? playingBarColor;

  /// Color for the portion of the progress bar that is buffered.
  /// Defaults to [Color(0x61FFFFFF)] if not provided.
  final Color? bufferedBarColor;

  /// Color for the circle handle on the progress bar.
  /// Defaults to [Colors.red] if not provided.
  final Color? circleHandlerColor;

  const MaxPlayerTheme({
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
    this.iconColor,
    this.playingBarColor,
    this.bufferedBarColor,
    this.circleHandlerColor,
  });

  MaxPlayerTheme copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? iconColor,
    Color? playingBarColor,
    Color? bufferedBarColor,
    Color? circleHandlerColor,
  }) {
    return MaxPlayerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      playingBarColor: playingBarColor ?? this.playingBarColor,
      bufferedBarColor: bufferedBarColor ?? this.bufferedBarColor,
      circleHandlerColor: circleHandlerColor ?? this.circleHandlerColor,
    );
  }
}
