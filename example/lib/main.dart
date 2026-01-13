import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:max_player/max_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Max Player Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Max Player Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MaxPlayerController _maxPlayerController;

  @override
  void initState() {
    super.initState();
    _maxPlayerController = MaxPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
      maxPlayerConfig: const MaxPlayerConfig(
        autoPlay: true,
        isLooping: false,
        wakelockEnabled: true,
        videoQualityPriority: [1080, 720, 360],
        theme: MaxPlayerTheme(
          primaryColor: Colors.deepPurple,
          accentColor: Colors.purpleAccent,
          backgroundColor: Colors.black,
          iconColor: Colors.white,
          playingBarColor: Colors.deepPurple,
          bufferedBarColor: Colors.grey,
          circleHandlerColor: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _maxPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: MaxVideoPlayer(
            controller: _maxPlayerController,
            frameAspectRatio: 16 / 9,
            videoAspectRatio: 16 / 9,
            alwaysShowProgressBar: true,
            matchVideoAspectRatioToFrame: true,
            videoTitle: const Text(
              'Butterfly Video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            videoThumbnail: const DecorationImage(
              image: NetworkImage(
                'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.jpg',
              ),
              fit: BoxFit.cover,
            ),
            maxPlayerLabels: const MaxPlayerLabels(
              play: 'Play',
              pause: 'Pause',
              mute: 'Mute',
              unmute: 'Unmute',
              settings: 'Settings',
              loopVideo: 'Loop',
              playbackSpeed: 'Speed',
              quality: 'Quality',
              optionEnabled: 'On',
              optionDisabled: 'Off',
              error: 'Oops! Error loading video.',
            ),
            maxProgressBarConfig: const MaxProgressBarConfig(
              playingBarColor: Colors.deepPurple,
              bufferedBarColor: Colors.white24,
              circleHandlerColor: Colors.deepPurpleAccent,
              height: 4.0,
              circleHandlerRadius: 6.0,
            ),
            onToggleFullScreen: (isFullScreen) async {
              if (isFullScreen) {
                await SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.manual,
                  overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                );
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              } else {
                await SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky,
                );
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _maxPlayerController.changeVideo(
            playVideoFrom: PlayVideoFrom.network(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
