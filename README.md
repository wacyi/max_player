<div align="center">
  <img src="mx_logo.png" height="200" alt="Max Player Logo"/>
  <h1>Max Player</h1>

[![pub package](https://img.shields.io/pub/v/max_player.svg)](https://pub.dev/packages/max_player)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-green.svg)](https://flutter.dev)

</div>

A professional, production-ready video player for Flutter. Built on `video_player` and `flutter_riverpod` with a YouTube-style UI out of the box.

## Features

- **Multiple Sources** — Network, Assets, Files, YouTube, Vimeo, Vimeo Private
- **YouTube-Style Controls** — Gradient overlays, double-tap seek, auto-hide controls
- **Playback Speed** — Configurable speed selector (0.5x to 3x)
- **Position & Status Streams** — Real-time position, buffered position, and player status
- **Error Handling** — Error stream, auto-retry, built-in error UI with retry button
- **Buffering Timeout** — Detects stuck buffering and surfaces timeout errors
- **Quality Control** — Multiple video qualities (Network & Vimeo)
- **Fullscreen** — Landscape + immersive mode, auto-rotation
- **Customizable Theme** — Colors, progress bar, labels, loading widget
- **Thumbnail** — Display a thumbnail before the video starts
- **Wakelock** — Keep screen on during playback
- **iOS + Android** — Mobile-only, no web/desktop

## Installation

```yaml
dependencies:
  max_player: ^3.0.0
```

> **Important:** Wrap your app with `ProviderScope` (from `flutter_riverpod`):

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

## Quick Start

```dart
import 'package:max_player/max_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final MaxPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        'https://example.com/video.mp4',
      ),
    );
    _controller.initialise();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: MaxVideoPlayer(controller: _controller),
        ),
      ),
    );
  }
}
```

## Video Sources

### Network

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.network(
    'https://example.com/video.mp4',
  ),
);
```

### YouTube

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.youtube(
    'https://www.youtube.com/watch?v=VIDEO_ID',
    live: false, // Set true for live streams
  ),
);
```

### Vimeo

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.vimeo('VIMEO_VIDEO_ID'),
);
```

### Vimeo Private

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.vimeoPrivateVideos(
    'VIMEO_VIDEO_ID',
    httpHeaders: {'Authorization': 'Bearer YOUR_TOKEN'},
  ),
);
```

### Asset

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.asset('assets/videos/video.mp4'),
);
```

### File

```dart
import 'dart:io';

MaxPlayerController(
  playVideoFrom: PlayVideoFrom.file(File('/path/to/video.mp4')),
);
```

### Network Quality URLs

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.networkQualityUrls(
    videoUrls: [
      VideoQalityUrls(quality: 360, url: 'https://example.com/360.mp4'),
      VideoQalityUrls(quality: 720, url: 'https://example.com/720.mp4'),
      VideoQalityUrls(quality: 1080, url: 'https://example.com/1080.mp4'),
    ],
  ),
);
```

## Configuration

### MaxPlayerConfig

```dart
MaxPlayerController(
  playVideoFrom: PlayVideoFrom.network('https://example.com/video.mp4'),
  maxPlayerConfig: const MaxPlayerConfig(
    autoPlay: true,                    // Auto-play on init (default: true)
    isLooping: false,                  // Loop video (default: false)
    wakelockEnabled: true,             // Keep screen on (default: true)
    videoQualityPriority: [1080, 720, 360],  // Quality preference order
    availableSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],  // Speed options
    positionStreamInterval: Duration(milliseconds: 500),   // Position update rate
    bufferingTimeoutDuration: Duration(seconds: 15),       // Buffering timeout
    theme: MaxPlayerTheme(
      primaryColor: Colors.blue,
      iconColor: Colors.white,
      backgroundColor: Colors.black,
      playingBarColor: Colors.blue,
      bufferedBarColor: Colors.grey,
      circleHandlerColor: Colors.blueAccent,
    ),
  ),
);
```

### Player Widget Options

```dart
MaxVideoPlayer(
  controller: _controller,
  frameAspectRatio: 16 / 9,
  videoAspectRatio: 16 / 9,
  alwaysShowProgressBar: true,
  matchVideoAspectRatioToFrame: true,
  videoTitle: const Text('Video Title', style: TextStyle(color: Colors.white)),
  videoThumbnail: const DecorationImage(
    image: NetworkImage('https://example.com/thumb.jpg'),
    fit: BoxFit.cover,
  ),
  maxProgressBarConfig: const MaxProgressBarConfig(
    playingBarColor: Colors.blue,
    bufferedBarColor: Colors.white24,
    circleHandlerColor: Colors.blueAccent,
    height: 4,
    circleHandlerRadius: 7,
  ),
  maxPlayerLabels: const MaxPlayerLabels(
    play: 'Play',
    pause: 'Pause',
    settings: 'Settings',
    quality: 'Quality',
    playbackSpeed: 'Speed',
    loopVideo: 'Loop',
  ),
  onLoading: (context) => const CircularProgressIndicator(color: Colors.white),
);
```

## Controller API

### Playback

```dart
_controller.play();
_controller.pause();
_controller.togglePlayPause();
_controller.videoSeekTo(const Duration(seconds: 30));
_controller.videoSeekForward(const Duration(seconds: 10));
_controller.videoSeekBackward(const Duration(seconds: 10));
```

### Volume

```dart
_controller.mute();
_controller.unMute();
_controller.toggleVolume();
```

### Playback Speed

```dart
await _controller.setPlaybackSpeed(1.5);
print(_controller.currentSpeed); // 1.5
```

### Fullscreen

```dart
_controller.enableFullScreen();    // Landscape + immersive
_controller.disableFullScreen(context); // Back to portrait
```

### Change Video

```dart
_controller.changeVideo(
  playVideoFrom: PlayVideoFrom.network('https://example.com/other.mp4'),
);
```

### Retry After Error

```dart
await _controller.retry(); // Re-initializes from the same source
```

## Streams & State

### Position Stream

```dart
_controller.positionStream.listen((position) {
  print('Position: $position');
});
```

### Buffered Position Stream

```dart
_controller.bufferedPositionStream.listen((buffered) {
  print('Buffered to: $buffered');
});
```

### Status Stream

```dart
_controller.statusStream.listen((status) {
  // MaxPlayerStatus: idle, initializing, playing, paused, buffering, completed, error
  print('Status: ${status.name}');
});
```

### Error Stream

```dart
_controller.onError.listen((error) {
  // MaxPlayerError with type (network, format, source, timeout, unknown) and message
  print('Error: ${error.type} - ${error.message}');
});
```

### State Getters

```dart
_controller.isPlaying;        // bool
_controller.isPaused;         // bool
_controller.isBuffering;      // bool
_controller.progress;         // 0.0 to 1.0
_controller.totalDuration;    // Duration?
_controller.currentSpeed;     // double
_controller.isFullScreen;     // bool
_controller.isMute;           // bool
_controller.currentVideoPosition;  // Duration
_controller.totalVideoLength;      // Duration
```

## Platform Setup

### Android

For HTTP video URLs, add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:networkSecurityConfig="@xml/network_security_config">
```

Create `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### iOS

For HTTP video URLs, add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Example

See the [example](example/) directory for a complete app with multiple demos:

- Basic player with video list
- Playback speed & streams dashboard
- Error handling & retry
- Video list with thumbnails
- Custom themed player

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Author

**Abdirizak Abdalla**

- **Email**: [info@abdorizak.dev](mailto:info@abdorizak.dev)
- **GitHub**: [Abdirizak Abdalla](https://github.com/abdorizak)
- **Website**: [abdorizak.dev](https://abdorizak.dev)

## License

[MIT](https://choosealicense.com/licenses/mit/)
