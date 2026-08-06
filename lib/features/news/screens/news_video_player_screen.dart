import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_actions.dart';

class NewsVideoPlayerScreen extends StatefulWidget {
  const NewsVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
    this.description,
  });

  final String videoUrl;
  final String? title;
  final String? description;

  @override
  State<NewsVideoPlayerScreen> createState() => _NewsVideoPlayerScreenState();
}

class _NewsVideoPlayerScreenState extends State<NewsVideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {'Cache-Control': 'no-cache'},
      );
      await _videoController.initialize();
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          placeholder: const Center(
            child: CircularProgressIndicator(color: AppColors.goldLight),
          ),
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.goldLight,
            handleColor: AppColors.goldLight,
            bufferedColor: Colors.white38,
            backgroundColor: Colors.white12,
          ),
          cupertinoProgressColors: ChewieProgressColors(
            playedColor: AppColors.goldLight,
            handleColor: AppColors.goldLight,
            bufferedColor: Colors.white38,
            backgroundColor: Colors.white12,
          ),
          errorBuilder: (_, error) => Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        );
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _videoController.pause();
    _chewieController?.dispose();
    _videoController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle =
        (widget.title ?? '').isEmpty ? 'News Video' : widget.title!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          screenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Download',
            onPressed: () {
              MediaActions.downloadVideo(
                context,
                widget.videoUrl,
                name: _suggestedFilename(),
              );
            },
            icon: const Icon(Icons.download_rounded, color: Colors.white),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          _buildPlayer(),
          if ((widget.description ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                widget.description!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16.sp, color: AppColors.goldLight),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'Tap the Download icon above to save this video to your device.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    if (_initializing) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.goldLight),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 40),
              SizedBox(height: 10.h),
              Text(
                'Failed to play video',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }

    final chewie = _chewieController!;
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio > 0
          ? _videoController.value.aspectRatio
          : 16 / 9,
      child: Chewie(controller: chewie),
    );
  }

  String? _suggestedFilename() {
    final base =
        (widget.title ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (base.isEmpty) return null;
    return '${base}_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }
}
