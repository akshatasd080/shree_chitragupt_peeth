import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Plays the bundled temple bell using [video_player] (already in the app).
class TempleBellService {
  TempleBellService._();
  static final TempleBellService instance = TempleBellService._();

  static const assetPath = 'assets/sounds/temple_bell.mp3';

  VideoPlayerController? _controller;
  final _playingController = StreamController<bool>.broadcast();
  bool _prepared = false;

  Stream<bool> get playingStream => _playingController.stream;

  bool get isPlaying => _controller?.value.isPlaying ?? false;

  Future<void> prepare() async {
    if (_prepared && _controller != null) return;

    await _controller?.dispose();
    _controller = VideoPlayerController.asset(assetPath);
    _controller!.addListener(_syncPlayingState);

    await _controller!.initialize();
    await _controller!.setLooping(true);
    await _controller!.setVolume(0.85);
    _prepared = true;
  }

  void _syncPlayingState() {
    final playing = _controller?.value.isPlaying ?? false;
    _playingController.add(playing);
  }

  Future<void> play() async {
    try {
      await prepare();
      final controller = _controller;
      if (controller == null) return;
      if (controller.value.isPlaying) return;
      await controller.seekTo(Duration.zero);
      await controller.play();
      _playingController.add(true);
    } catch (e, st) {
      debugPrint('TempleBellService.play failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> pause() async {
    await _controller?.pause();
    _playingController.add(false);
  }

  Future<void> dispose() async {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_syncPlayingState);
      await controller.dispose();
    }
    _controller = null;
    _prepared = false;
  }
}
