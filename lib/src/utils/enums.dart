/// The state of the video player.
enum MaxVideoState {
  /// The video is loading.
  loading,

  /// The video is playing.
  playing,

  /// The video is paused.
  paused,

  /// The video has encountered an error.
  error,
}

/// The type of video source.
enum MaxVideoPlayerType {
  /// A network URL.
  network,

  /// Multiple quality network URLs.
  networkQualityUrls,

  /// A local file.
  file,

  /// A Flutter asset.
  asset,

  /// A Vimeo video.
  vimeo,

  /// A YouTube video.
  youtube,

  /// A private Vimeo video.
  vimeoPrivateVideos,
}

/// The status of the max player, providing more granular state info.
enum MaxPlayerStatus {
  /// Player is idle (not initialized).
  idle,

  /// Player is initializing the video source.
  initializing,

  /// Video is actively playing.
  playing,

  /// Video is paused.
  paused,

  /// Video is buffering.
  buffering,

  /// Video has completed playback.
  completed,

  /// An error occurred.
  error,
}

/// The type of error that occurred during playback.
enum MaxPlayerErrorType {
  /// A network connectivity error.
  network,

  /// The video format is unsupported.
  format,

  /// The video source could not be found or accessed.
  source,

  /// A timeout occurred (e.g. buffering too long).
  timeout,

  /// An unknown error.
  unknown,
}
