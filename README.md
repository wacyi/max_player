<div align="center">
  <img src="mx_logo.png" height="200" alt="Max Player Logo"/>
  <h1>Max Player</h1>
</div>

Max Player is a powerful and flexible video player package for Flutter. It supports playing videos from various sources including network URLs, local files, assets, YouTube, and Vimeo. Built on top of `video_player` and `flutter_riverpod`, it offers a customizable UI and a robust controller.

## Features

-   **Multiple Sources**: Play videos from Network, Assets, Files, YouTube, and Vimeo.
-   **Customizable UI**: Overlay builder for custom controls and UI elements.
-   **Responsive**: Supports full-screen mode, portrait, and landscape orientations.
-   **Controls**: Built-in support for play/pause, seek, volume control, and looping.
-   **Thumbnail**: Display a thumbnail before the video starts.

## Installation

Add `max_player` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

```yaml
dependencies:
  max_player: ^1.1.2
```

## Usage

### 1. Initialize the Controller

You need to initialize the `MaxPlayerController` with a `PlayVideoFrom` source.

#### Network Video
```dart
import 'package:max_player/max_player.dart';

MaxPlayerController _maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.network(
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
);
```

#### Asset Video
```dart
MaxPlayerController _maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.asset(
    'assets/videos/video.mp4',
  ),
);
```

#### File Video
```dart
import 'dart:io';

MaxPlayerController _maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.file(
    File('/path/to/video.mp4'),
  ),
);
```

#### YouTube Video
```dart
MaxPlayerController _maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.youtube(
    'https://www.youtube.com/watch?v=YOUR_VIDEO_ID',
  ),
);
```

#### Vimeo Video
```dart
MaxPlayerController _maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.vimeo(
    'YOUR_VIMEO_VIDEO_ID',
  ),
);
```

### 2. Implementation in Widget

Use the `MaxVideoPlayer` widget to display the player.

```dart
import 'package:flutter/material.dart';
import 'package:max_player/max_player.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late MaxPlayerController _maxController;

  @override
  void initState() {
    super.initState();
    _maxController = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
      maxPlayerConfig: MaxPlayerConfig(
        autoPlay: true,
        isLooping: false,
      ),
    );
     // Optional: Initialize immediately if needed, otherwise it lazy loads
    _maxController.initialise();
  }

  @override
  void dispose() {
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Max Player Example')),
      body: Center(
        child: MaxVideoPlayer(
          controller: _maxController,
          videoAspectRatio: 16 / 9,
          videoThumbnail: DecorationImage(
            image: NetworkImage('https://example.com/thumbnail.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

### 3. Controller Actions

The `MaxPlayerController` provides methods to control the playback programmatically:

```dart
// Play
_maxController.play();

// Pause
_maxController.pause();

// Toggle Play/Pause
_maxController.togglePlayPause();

// Seek
_maxController.videoSeekTo(Duration(seconds: 10));

// Mute/Unmute
_maxController.mute();
_maxController.unMute();

// Enter Fullscreen
_maxController.enableFullScreen();
```

### 4. Customizing Colors

You can customize the player colors using `MaxPlayerTheme` in `MaxPlayerConfig`:

```dart
_maxController = MaxPlayerController(
  playVideoFrom: PlayVideoFrom.network(
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ),
  maxPlayerConfig: MaxPlayerConfig(
    theme: MaxPlayerTheme(
      primaryColor: Colors.blue,
      iconColor: Colors.white,
      playingBarColor: Colors.blueAccent,
      bufferedBarColor: Colors.grey,
      backgroundColor: Colors.black,
    ),
  ),
);
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Author

**Abdirizak Abdalla**

- **Email**: [info@abdorizak.dev](mailto:info@abdorizak.dev)
- **GitHub**: [Abdirizak Abdalla](https://github.com/abdorizak)
- **Website**: [abdorizak.dev](https://abdorizak.dev)


## License

[MIT](https://choosealicense.com/licenses/mit/)
