part of 'max_video_controller.dart';

class _MaxBaseController extends ChangeNotifier {
  ///main video controller
  VideoPlayerController? _videoCtr;

  ///
  late MaxVideoPlayerType _videoPlayerType;

  bool isMute = false;
  bool autoPlay = true;

  ///
  MaxVideoState _maxVideoState = MaxVideoState.loading;

  ///
  Duration _videoDuration = Duration.zero;

  Duration _videoPosition = Duration.zero;

  String _currentPaybackSpeed = '1x';

  bool? isVideoUiBinded;

  bool? wasVideoPlayingOnUiDispose;

  int doubleTapForwardSeconds = 10;
  String? playingVideoUrl;

  late BuildContext mainContext;
  late BuildContext fullScreenContext;

  ///**listners

  Future<void> videoListner() async {
    if (!_videoCtr!.value.isInitialized) {
      await _videoCtr!.initialize();
    }
    if (_videoCtr!.value.isInitialized) {
      // _listneToVideoState();
      _listneToVideoPosition();
      _listneToVolume();
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

  ///updates state with id `_maxVideoState`
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

  /// Shim for GetX update method
  void update([List<Object>? ids, bool condition = true]) {
    if (condition) {
      notifyListeners();
    }
  }
}
