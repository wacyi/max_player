part of 'max_video_controller.dart';

class _MaxBaseController extends ChangeNotifier {
  /// Main video controller.
  VideoPlayerController? _videoCtr;

  late MaxVideoPlayerType _videoPlayerType;

  bool isMute = false;
  bool autoPlay = true;

  MaxVideoState _maxVideoState = MaxVideoState.loading;

  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  double _currentPlaybackSpeed = 1;

  bool? isVideoUiBinded;

  bool? wasVideoPlayingOnUiDispose;

  int doubleTapForwardSeconds = 10;
  String? playingVideoUrl;

  late BuildContext mainContext;
  late BuildContext fullScreenContext;

  // -- Streams (Phase 1b) --

  final StreamController<Duration> _positionStreamController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _bufferedPositionStreamController =
      StreamController<Duration>.broadcast();
  final StreamController<MaxPlayerStatus> _statusStreamController =
      StreamController<MaxPlayerStatus>.broadcast();
  final StreamController<MaxPlayerError> _errorStreamController =
      StreamController<MaxPlayerError>.broadcast();

  Timer? _positionTimer;
  Timer? _bufferingTimeoutTimer;
  MaxPlayerStatus _currentStatus = MaxPlayerStatus.idle;

  /// Stream of the current playback position.
  Stream<Duration> get positionStream => _positionStreamController.stream;

  /// Stream of the buffered position.
  Stream<Duration> get bufferedPositionStream =>
      _bufferedPositionStreamController.stream;

  /// Stream of player status changes.
  Stream<MaxPlayerStatus> get statusStream => _statusStreamController.stream;

  /// Stream of player errors.
  Stream<MaxPlayerError> get onError => _errorStreamController.stream;

  /// The total duration of the video, or `null` if not yet known.
  Duration? get totalDuration {
    final duration = _videoCtr?.value.duration;
    if (duration == null || duration == Duration.zero) return null;
    return duration;
  }

  /// The current playback progress as a value from 0.0 to 1.0.
  double get progress {
    final total = _videoCtr?.value.duration;
    final position = _videoCtr?.value.position;
    if (total == null ||
        position == null ||
        total.inMilliseconds == 0) {
      return 0;
    }
    return (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Whether the video is currently playing.
  bool get isPlaying => _videoCtr?.value.isPlaying ?? false;

  /// Whether the video is currently paused.
  bool get isPaused =>
      _videoCtr != null &&
      (_videoCtr!.value.isInitialized) &&
      !_videoCtr!.value.isPlaying;

  /// Whether the video is currently buffering.
  bool get isBuffering => _videoCtr?.value.isBuffering ?? false;

  // -- Listeners --

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      _listneToVideoPosition();
      _listneToVolume();
      _updatePlayerStatus();
    }
  }

  void _listneToVolume() {
    if (_videoCtr!.value.volume == 0) {
      if (!isMute) {
        isMute = true;
        update(['volume']);
        update(['update-all']);
      }
    } else {
      if (isMute) {
        isMute = false;
        update(['volume']);
        update(['update-all']);
      }
    }
  }

  /// Updates state with id `_maxVideoState`.
  void maxVideoStateChanger(MaxVideoState? val, {bool updateUi = true}) {
    if (_maxVideoState != (val ?? _maxVideoState)) {
      _maxVideoState = val ?? _maxVideoState;
      if (updateUi) {
        update(['maxVideoState']);
        update(['update-all']);
      }
    }
  }

  void _listneToVideoPosition() {
    if ((_videoCtr?.value.duration.inSeconds ?? Duration.zero.inSeconds) < 60) {
      _videoPosition = _videoCtr?.value.position ?? Duration.zero;
      update(['video-progress']);
      update(['update-all']);
    } else {
      if (_videoPosition.inSeconds !=
          (_videoCtr?.value.position ?? Duration.zero).inSeconds) {
        _videoPosition = _videoCtr?.value.position ?? Duration.zero;
        update(['video-progress']);
        update(['update-all']);
      }
    }
  }

  void _updatePlayerStatus() {
    MaxPlayerStatus newStatus;

    if (_maxVideoState == MaxVideoState.error) {
      newStatus = MaxPlayerStatus.error;
    } else if (_videoCtr?.value.isBuffering ?? false) {
      newStatus = MaxPlayerStatus.buffering;
    } else if (_videoCtr?.value.isPlaying ?? false) {
      newStatus = MaxPlayerStatus.playing;
      _cancelBufferingTimeout();
    } else if (_videoCtr?.value.position != null &&
        _videoCtr?.value.duration != null &&
        _videoCtr!.value.position >= _videoCtr!.value.duration &&
        _videoCtr!.value.duration > Duration.zero) {
      newStatus = MaxPlayerStatus.completed;
    } else {
      newStatus = MaxPlayerStatus.paused;
    }

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      if (!_statusStreamController.isClosed) {
        _statusStreamController.add(newStatus);
      }

      // Start buffering timeout if buffering.
      if (newStatus == MaxPlayerStatus.buffering) {
        _startBufferingTimeout();
      } else {
        _cancelBufferingTimeout();
      }
    }
  }

  /// Starts the position stream timer.
  void _startPositionStream(Duration interval) {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(interval, (_) {
      if (_videoCtr != null && !_positionStreamController.isClosed) {
        _positionStreamController.add(
          _videoCtr!.value.position,
        );

        // Emit buffered position.
        final buffered = _videoCtr!.value.buffered;
        if (buffered.isNotEmpty &&
            !_bufferedPositionStreamController.isClosed) {
          _bufferedPositionStreamController.add(buffered.last.end);
        }
      }
    });
  }

  void _startBufferingTimeout() {
    // Will be configured once maxPlayerConfig is available.
  }

  void _cancelBufferingTimeout() {
    _bufferingTimeoutTimer?.cancel();
    _bufferingTimeoutTimer = null;
  }

  /// Emits a [MaxPlayerError] on the error stream.
  void emitError(MaxPlayerError error) {
    if (!_errorStreamController.isClosed) {
      _errorStreamController.add(error);
    }
  }

  void _disposeStreams() {
    _positionTimer?.cancel();
    _bufferingTimeoutTimer?.cancel();
    unawaited(_positionStreamController.close());
    unawaited(_bufferedPositionStreamController.close());
    unawaited(_statusStreamController.close());
    unawaited(_errorStreamController.close());
  }

  /// Shim for GetX update method.
  // ignore: avoid_positional_boolean_parameters
  void update([List<Object>? ids, bool condition = true]) {
    if (condition) {
      notifyListeners();
    }
  }
}
