import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:max_player/max_player.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ---------------------------------------------------------------------------
// Sample video data
// ---------------------------------------------------------------------------

class SampleVideo {
  const SampleVideo({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.thumb,
  });

  final String title;
  final String subtitle;
  final String url;
  final String thumb;
}

const _sampleVideos = [
  SampleVideo(
    title: 'Big Buck Bunny',
    subtitle: 'By Blender Foundation',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
  ),
  SampleVideo(
    title: 'Elephant Dream',
    subtitle: 'By Blender Foundation',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
  ),
  SampleVideo(
    title: 'For Bigger Blazes',
    subtitle: 'By Google',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
  ),
  SampleVideo(
    title: 'For Bigger Escape',
    subtitle: 'By Google',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
  ),
  SampleVideo(
    title: 'For Bigger Fun',
    subtitle: 'By Google',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
  ),
  SampleVideo(
    title: 'For Bigger Joyrides',
    subtitle: 'By Google',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
  ),
  SampleVideo(
    title: 'For Bigger Meltdowns',
    subtitle: 'By Google',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
  ),
  SampleVideo(
    title: 'Sintel',
    subtitle: 'By Blender Foundation',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
  ),
  SampleVideo(
    title: 'Subaru Outback On Street And Dirt',
    subtitle: 'By Garage419',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
  ),
  SampleVideo(
    title: 'Tears of Steel',
    subtitle: 'By Blender Foundation',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
  ),
  SampleVideo(
    title: 'Volkswagen GTI Review',
    subtitle: 'By Garage419',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg',
  ),
  SampleVideo(
    title: 'We Are Going On Bullrun',
    subtitle: 'By Garage419',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg',
  ),
  SampleVideo(
    title: 'What car can you get for a grand?',
    subtitle: 'By Garage419',
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
    thumb:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WhatCarCanYouGetForAGrand.jpg',
  ),
];

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Max Player Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Max Player Examples'),
      ),
      body: ListView(
        children: [
          _ExampleTile(
            icon: Icons.play_circle_outline,
            title: 'Basic Player',
            subtitle: 'Tap a video to play',
            builder: (_) => const BasicPlayerExample(),
          ),
          _ExampleTile(
            icon: Icons.speed,
            title: 'Playback Speed & Streams',
            subtitle: 'Speed control, position stream, status stream',
            builder: (_) => const SpeedAndStreamsExample(),
          ),
          _ExampleTile(
            icon: Icons.error_outline,
            title: 'Error Handling & Retry',
            subtitle: 'Invalid URL to test error UI and retry',
            builder: (_) => const ErrorHandlingExample(),
          ),
          _ExampleTile(
            icon: Icons.swap_horiz,
            title: 'Video List',
            subtitle: 'Browse and switch between videos',
            builder: (_) => const VideoListExample(),
          ),
          _ExampleTile(
            icon: Icons.palette,
            title: 'Custom Theme',
            subtitle: 'Themed player with custom colors & labels',
            builder: (_) => const CustomThemeExample(),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: builder),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Basic Player — pick from sample videos
// ---------------------------------------------------------------------------

class BasicPlayerExample extends StatefulWidget {
  const BasicPlayerExample({super.key});

  @override
  State<BasicPlayerExample> createState() => _BasicPlayerExampleState();
}

class _BasicPlayerExampleState extends State<BasicPlayerExample> {
  late final MaxPlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(_sampleVideos[0].url),
    );
    unawaited(_controller.initialise());
  }

  void _playVideo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _controller.changeVideo(
      playVideoFrom: PlayVideoFrom.network(_sampleVideos[index].url),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _sampleVideos[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Player')),
      body: Column(
        children: [
          // Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: MaxVideoPlayer(
              controller: _controller,
              videoTitle: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  current.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              videoThumbnail: DecorationImage(
                image: NetworkImage(current.thumb),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Video list
          Expanded(
            child: ListView.builder(
              itemCount: _sampleVideos.length,
              itemBuilder: (context, index) {
                final video = _sampleVideos[index];
                final isPlaying = index == _currentIndex;
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      video.thumb,
                      width: 80,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                        width: 80,
                        height: 45,
                        child: ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.movie),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isPlaying ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(video.subtitle),
                  trailing: isPlaying
                      ? const Icon(
                          Icons.play_arrow,
                          color: Colors.deepPurple,
                        )
                      : null,
                  selected: isPlaying,
                  onTap: () => _playVideo(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Playback Speed & Streams
// ---------------------------------------------------------------------------

class SpeedAndStreamsExample extends StatefulWidget {
  const SpeedAndStreamsExample({super.key});

  @override
  State<SpeedAndStreamsExample> createState() => _SpeedAndStreamsExampleState();
}

class _SpeedAndStreamsExampleState extends State<SpeedAndStreamsExample> {
  late final MaxPlayerController _controller;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<MaxPlayerStatus>? _statusSub;

  Duration _position = Duration.zero;
  double _progress = 0;
  MaxPlayerStatus _status = MaxPlayerStatus.idle;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    final video = _sampleVideos[0]; // Big Buck Bunny
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(video.url),
      maxPlayerConfig: const MaxPlayerConfig(
        availableSpeeds: [0.5, 1.0, 1.5, 2.0],
      ),
    );
    unawaited(_controller.initialise());

    _positionSub = _controller.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
          _progress = _controller.progress;
        });
      }
    });

    _statusSub = _controller.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _statusSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speed & Streams')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MaxVideoPlayer(
                controller: _controller,
                videoTitle: const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'Big Buck Bunny',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                videoThumbnail: DecorationImage(
                  image: NetworkImage(_sampleVideos[0].thumb),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stream info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_status.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Position: ${_formatDuration(_position)} / '
                        '${_formatDuration(_controller.totalVideoLength)}',
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 8),
                      Text(
                        'Progress: '
                        '${(_progress * 100).toStringAsFixed(1)}%',
                      ),
                      Text('isPlaying: ${_controller.isPlaying}'),
                      Text('isBuffering: ${_controller.isBuffering}'),
                      Text(
                        'Total duration: ${_controller.totalDuration}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Speed controls card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Playback Speed: ${_speed}x',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                            .map(
                              (speed) => ChoiceChip(
                                label: Text('${speed}x'),
                                selected: _speed == speed,
                                onSelected: (_) async {
                                  await _controller
                                      .setPlaybackSpeed(speed);
                                  setState(() => _speed = speed);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Error Handling & Retry
// ---------------------------------------------------------------------------

class ErrorHandlingExample extends StatefulWidget {
  const ErrorHandlingExample({super.key});

  @override
  State<ErrorHandlingExample> createState() => _ErrorHandlingExampleState();
}

class _ErrorHandlingExampleState extends State<ErrorHandlingExample> {
  late MaxPlayerController _controller;
  StreamSubscription<MaxPlayerError>? _errorSub;
  String _lastError = 'No errors yet';

  @override
  void initState() {
    super.initState();
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        'https://invalid-url.example.com/video.mp4',
      ),
    );
    unawaited(_controller.initialise());

    _errorSub = _controller.onError.listen((error) {
      if (mounted) {
        setState(() {
          _lastError = '${error.type.name}: ${error.message}';
        });
      }
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling & Retry')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MaxVideoPlayer(controller: _controller),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Stream',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastError,
                        style: TextStyle(
                          color: _lastError == 'No errors yet'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              unawaited(_controller.retry());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _controller.changeVideo(
                                playVideoFrom: PlayVideoFrom.network(
                                  _sampleVideos[0].url,
                                ),
                              );
                              setState(
                                () => _lastError =
                                    'Switched to Big Buck Bunny',
                              );
                            },
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Load valid video'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Video List — browse & switch
// ---------------------------------------------------------------------------

class VideoListExample extends StatefulWidget {
  const VideoListExample({super.key});

  @override
  State<VideoListExample> createState() => _VideoListExampleState();
}

class _VideoListExampleState extends State<VideoListExample> {
  late final MaxPlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(_sampleVideos[0].url),
    );
    unawaited(_controller.initialise());
  }

  void _playVideo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _controller.changeVideo(
      playVideoFrom: PlayVideoFrom.network(
        _sampleVideos[index].url,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _sampleVideos[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Video List')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: MaxVideoPlayer(
              controller: _controller,
              videoTitle: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      current.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      current.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              videoThumbnail: DecorationImage(
                image: NetworkImage(current.thumb),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Up Next',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _sampleVideos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final video = _sampleVideos[index];
                final isPlaying = index == _currentIndex;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          video.thumb,
                          width: 100,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                            width: 100,
                            height: 56,
                            child: ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.movie),
                            ),
                          ),
                        ),
                      ),
                      if (isPlaying)
                        Container(
                          width: 100,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isPlaying
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isPlaying ? Colors.deepPurple : null,
                    ),
                  ),
                  subtitle: Text(
                    video.subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _playVideo(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Custom Theme
// ---------------------------------------------------------------------------

class CustomThemeExample extends StatefulWidget {
  const CustomThemeExample({super.key});

  @override
  State<CustomThemeExample> createState() => _CustomThemeExampleState();
}

class _CustomThemeExampleState extends State<CustomThemeExample> {
  late final MaxPlayerController _controller;

  @override
  void initState() {
    super.initState();
    final video = _sampleVideos[7]; // Sintel
    _controller = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(video.url),
      maxPlayerConfig: const MaxPlayerConfig(
        availableSpeeds: [0.5, 1.0, 1.5, 2.0, 3.0],
        theme: MaxPlayerTheme(
          primaryColor: Colors.teal,
          accentColor: Colors.tealAccent,
          backgroundColor: Color(0xFF1A1A2E),
          iconColor: Colors.tealAccent,
          playingBarColor: Colors.teal,
          bufferedBarColor: Colors.white24,
          circleHandlerColor: Colors.tealAccent,
        ),
      ),
    );
    unawaited(_controller.initialise());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _sampleVideos[7]; // Sintel
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Theme'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MaxVideoPlayer(
                controller: _controller,
                videoTitle: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                videoThumbnail: DecorationImage(
                  image: NetworkImage(video.thumb),
                  fit: BoxFit.cover,
                ),
                maxProgressBarConfig: const MaxProgressBarConfig(
                  playingBarColor: Colors.teal,
                  bufferedBarColor: Colors.white24,
                  circleHandlerColor: Colors.tealAccent,
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
                // Default fullscreen behavior:
                // Enter → landscape + immersive
                // Exit → portrait + system UI restored
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Custom teal theme with:\n'
                '• Custom icon & progress bar colors\n'
                '• Custom speed options: 0.5x, 1x, 1.5x, 2x, 3x\n'
                '• Custom labels\n'
                '• Thumbnail image\n'
                '• Fullscreen orientation handling',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
