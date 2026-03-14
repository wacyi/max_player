import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:max_player/src/models/vimeo_models.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

String maxErrorString(String val) {
  return '*\n------error------\n\n$val'
      '\n\n------end------\n*';
}

class VideoApis {
  static Future<Response<Map<String, dynamic>>>
      _makeRequestHash(
    String videoId,
    String? hash,
  ) {
    final url = hash == null
        ? 'https://player.vimeo.com'
            '/video/$videoId/config'
        : 'https://player.vimeo.com'
            '/video/$videoId/config?h=$hash';
    return Dio().get<Map<String, dynamic>>(url);
  }

  static Future<List<VideoQalityUrls>?>
      getVimeoVideoQualityUrls(
    String videoId,
    String? hash,
  ) async {
    try {
      final response =
          await _makeRequestHash(videoId, hash);
      final data = response.data!;
      final request =
          data['request'] as Map<String, dynamic>;
      final files =
          request['files'] as Map<String, dynamic>;
      final progressive =
          files['progressive'] as List<dynamic>;

      final progressiveUrls = List.generate(
        progressive.length,
        (index) {
          final item =
              progressive[index] as Map<String, dynamic>;
          return VideoQalityUrls(
            quality: int.parse(
              (item['quality'] as String?)
                      ?.split('p')
                      .first ??
                  '0',
            ),
            url: item['url'] as String,
          );
        },
      );

      if (progressiveUrls.isEmpty) {
        final hls =
            files['hls'] as Map<String, dynamic>;
        final cdns =
            hls['cdns'] as Map<String, dynamic>;
        for (final entry in cdns.entries) {
          final cdn =
              entry.value as Map<String, dynamic>;
          progressiveUrls.add(
            VideoQalityUrls(
              quality: 720,
              url: cdn['url'] as String,
            ),
          );
          break;
        }
      }
      return progressiveUrls;
    } catch (error) {
      if (error
          .toString()
          .contains('XMLHttpRequest')) {
        log(
          maxErrorString(
            '(INFO) To play vimeo video in WEB, '
            'Please enable CORS in your browser',
          ),
        );
      }
      debugPrint(
        '===== VIMEO API ERROR: $error '
        '==========',
      );
      rethrow;
    }
  }

  static Future<List<VideoQalityUrls>?>
      getVimeoPrivateVideoQualityUrls(
    String videoId,
    Map<String, String> httpHeader,
  ) async {
    try {
      final response =
          await Dio().get<Map<String, dynamic>>(
        'https://api.vimeo.com/videos/$videoId',
        options: Options(headers: httpHeader),
      );

      final data = response.data!;
      final jsonFiles =
          data['files'] as List<dynamic>;

      final list = <VideoQalityUrls>[];
      for (var i = 0; i < jsonFiles.length; i++) {
        final item =
            jsonFiles[i] as Map<String, dynamic>;
        final quality =
            (item['rendition'] as String?)
                    ?.split('p')
                    .first ??
                '0';
        final number = int.tryParse(quality);
        if (number != null && number != 0) {
          list.add(
            VideoQalityUrls(
              quality: number,
              url: item['link'] as String,
            ),
          );
        }
      }
      return list;
    } catch (error) {
      if (error
          .toString()
          .contains('XMLHttpRequest')) {
        log(
          maxErrorString(
            '(INFO) To play vimeo video in WEB, '
            'Please enable CORS in your browser',
          ),
        );
      }
      debugPrint(
        '===== VIMEO API ERROR: $error '
        '==========',
      );
      rethrow;
    }
  }

  static Future<List<VideoQalityUrls>?>
      getYoutubeVideoQualityUrls(
    String youtubeIdOrUrl,
    // ignore: avoid_positional_boolean_parameters - existing API
    bool live,
  ) async {
    try {
      final yt = YoutubeExplode();
      final urls = <VideoQalityUrls>[];
      if (live) {
        await _extractLiveStreamUrls(
          yt,
          youtubeIdOrUrl,
          urls,
        );
      } else {
        await _extractVideoUrls(
          yt,
          youtubeIdOrUrl,
          urls,
        );
      }
      yt.close();
      return urls;
    } catch (error) {
      if (error
          .toString()
          .contains('XMLHttpRequest')) {
        log(
          maxErrorString(
            '(INFO) To play youtube video in '
            'WEB, Please enable CORS in '
            'your browser',
          ),
        );
      }
      debugPrint(
        '===== YOUTUBE API ERROR: $error '
        '==========',
      );
      rethrow;
    }
  }

  static Future<void> _extractLiveStreamUrls(
    YoutubeExplode yt,
    String youtubeIdOrUrl,
    List<VideoQalityUrls> urls,
  ) async {
    try {
      // Try direct HLS manifest URL first.
      final url = await yt
          .videos.streamsClient
          .getHttpLiveStreamUrl(
        VideoId(youtubeIdOrUrl),
      );
      urls.add(
        VideoQalityUrls(quality: 360, url: url),
      );
    } on Exception catch (_) {
      // Fallback: use getManifest which supports
      // live streams in youtube_explode_dart 3.x.
      debugPrint(
        '===== Live HLS URL failed, '
        'falling back to manifest =====',
      );
      await _extractFromManifest(
        yt,
        youtubeIdOrUrl,
        urls,
      );
    }
  }

  static Future<void> _extractVideoUrls(
    YoutubeExplode yt,
    String youtubeIdOrUrl,
    List<VideoQalityUrls> urls,
  ) async {
    final manifest = await yt
        .videos.streamsClient
        .getManifest(youtubeIdOrUrl);
    urls.addAll(
      manifest.muxed.map(
        (element) => VideoQalityUrls(
          quality: int.parse(
            element.qualityLabel.split('p')[0],
          ),
          url: element.url.toString(),
        ),
      ),
    );
  }

  static Future<void> _extractFromManifest(
    YoutubeExplode yt,
    String youtubeIdOrUrl,
    List<VideoQalityUrls> urls,
  ) async {
    final manifest = await yt
        .videos.streamsClient
        .getManifest(
      youtubeIdOrUrl,
      requireWatchPage: false,
    );

    // Prefer HLS streams for live content.
    if (manifest.hls.isNotEmpty) {
      for (final stream in manifest.hls) {
        final quality = int.tryParse(
              stream.qualityLabel.split('p')[0],
            ) ??
            360;
        urls.add(
          VideoQalityUrls(
            quality: quality,
            url: stream.url.toString(),
          ),
        );
      }
    }

    // Fallback to muxed streams if no HLS.
    if (urls.isEmpty && manifest.muxed.isNotEmpty) {
      urls.addAll(
        manifest.muxed.map(
          (e) => VideoQalityUrls(
            quality: int.tryParse(
                  e.qualityLabel.split('p')[0],
                ) ??
                360,
            url: e.url.toString(),
          ),
        ),
      );
    }

    // Last resort: video-only streams.
    if (urls.isEmpty && manifest.videoOnly.isNotEmpty) {
      urls.addAll(
        manifest.videoOnly.map(
          (e) => VideoQalityUrls(
            quality: int.tryParse(
                  e.qualityLabel.split('p')[0],
                ) ??
                360,
            url: e.url.toString(),
          ),
        ),
      );
    }
  }
}
