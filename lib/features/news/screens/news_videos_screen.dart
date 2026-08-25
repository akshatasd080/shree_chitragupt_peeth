import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_actions.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';
import 'news_video_player_screen.dart';

class NewsVideosScreen extends StatefulWidget {
  const NewsVideosScreen({super.key});

  @override
  State<NewsVideosScreen> createState() => _NewsVideosScreenState();
}

class _NewsVideosScreenState extends State<NewsVideosScreen>
    with WidgetsBindingObserver {
  final _service = ContentService();
  late Future<List<NewsVideoItem>> _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _service.fetchNewsVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reload();
    }
  }

  Future<void> reload() async {
    setState(() {
      _future = _service.fetchNewsVideos();
    });
    await _future;
  }

  Future<void> _reload() => reload();

  void _openPlayer(NewsVideoItem item) {
    final url = ApiConfig.newsVideo(item.videoFilename);
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsVideoPlayerScreen(
          videoUrl: url,
          title: 'News Video #${item.id}',
          description: item.description,
        ),
      ),
    );
  }

  Future<void> _download(NewsVideoItem item) async {
    final url = ApiConfig.newsVideo(item.videoFilename);
    if (url.isEmpty) return;
    await MediaActions.downloadVideo(
      context,
      url,
      name:
          'news_video_${item.id}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: FutureBuilder<List<NewsVideoItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingCard();
            }
            if (snapshot.hasError) {
              return ListView(
                padding: EdgeInsets.all(18.w),
                children: [
                  const SectionTitle(
                    title: 'News Videos',
                    subtitle: 'Video news from Admin Panel',
                    icon: Icons.videocam_outlined,
                  ),
                  SizedBox(height: 16.h),
                  EmptyStateCard(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  ),
                ],
              );
            }

            final items = snapshot.data ?? [];
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
              itemCount: items.isEmpty ? 2 : items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const SectionTitle(
                      title: 'News Videos',
                      subtitle: 'Video news from Admin Panel',
                      icon: Icons.videocam_outlined,
                    ),
                  );
                }
                if (items.isEmpty) {
                  return const EmptyStateCard(
                    message: 'No news videos yet.',
                  );
                }
                final item = items[index - 1];
                final url = ApiConfig.newsVideo(item.videoFilename);
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _openPlayer(item),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180.h,
                                width: double.infinity,
                                child: url.isEmpty
                                    ? const _NewsVideoThumbFallback()
                                    : _NewsVideoThumbnail(videoUrl: url),
                              ),
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: AppColors.saffron.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 36.sp,
                                ),
                              ),
                              Positioned(
                                left: 10.w,
                                bottom: 10.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline_rounded,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Preview',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (url.isNotEmpty)
                                Positioned(
                                  right: 10.w,
                                  bottom: 10.h,
                                  child: Material(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: InkWell(
                                      onTap: () => _download(item),
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.download_rounded,
                                              color: AppColors.goldLight,
                                              size: 14.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Download',
                                              style: TextStyle(
                                                color: AppColors.goldLight,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _openPlayer(item),
                          child: Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((item.description ?? '').isNotEmpty)
                                  Text(
                                    item.description!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  )
                                else
                                  Text(
                                    'News Video #${item.id}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      size: 14.sp,
                                      color: AppColors.goldLight,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Tap thumbnail to watch in-app',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Loads the first frame of an uploaded news video as a list thumbnail.
class _NewsVideoThumbnail extends StatefulWidget {
  const _NewsVideoThumbnail({required this.videoUrl});

  final String videoUrl;

  @override
  State<_NewsVideoThumbnail> createState() => _NewsVideoThumbnailState();
}

class _NewsVideoThumbnailState extends State<_NewsVideoThumbnail> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _NewsVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _ready = false;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: const {'Cache-Control': 'no-cache'},
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.pause();
      // Skip pure-black intros when possible so the preview is useful.
      final duration = controller.value.duration;
      if (duration > const Duration(milliseconds: 400)) {
        await controller.seekTo(const Duration(milliseconds: 350));
      }
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !_ready || _controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const _NewsVideoThumbFallback(),
          if (!_failed && !_ready)
            Center(
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
        ],
      );
    }

    final size = _controller!.value.size;
    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width > 0 ? size.width : 16,
          height: size.height > 0 ? size.height : 9,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}

class _NewsVideoThumbFallback extends StatelessWidget {
  const _NewsVideoThumbFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.saffron.withOpacity(0.85),
            const Color(0xFF1A0A2E).withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_rounded,
          color: Colors.white.withOpacity(0.25),
          size: 72.sp,
        ),
      ),
    );
  }
}
