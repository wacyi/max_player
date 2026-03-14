import 'package:max_player/src/utils/enums.dart';

/// Represents an error that occurred during video playback.
class MaxPlayerError {
  /// Creates a [MaxPlayerError].
  const MaxPlayerError({
    required this.type,
    required this.message,
    this.exception,
  });

  /// The type of error.
  final MaxPlayerErrorType type;

  /// A human-readable error message.
  final String message;

  /// The original exception, if available.
  final Object? exception;

  @override
  String toString() => 'MaxPlayerError($type: $message)';
}
