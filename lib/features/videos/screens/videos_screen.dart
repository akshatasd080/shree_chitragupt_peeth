import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_utils.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final _service = ContentService();
  late Future<List<YoutubeVideoItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchYoutubeVideos(latest: true, limit: 100);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchYoutubeVideos(latest: true, limit: 100);
    });
    await _future;
  }

  void _openVideo(YoutubeVideoItem video) {
    final id = YoutubeUtils.extractVideoId(video.youtubeUrl);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoPlayerScreen(
          videoId: id,
          title: video.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: FutureBuilder<List<YoutubeVideoItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingCard();
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
                children: [
                  const SectionTitle(
                    title: 'YouTube Videos',
                    subtitle: 'From Admin Panel',
                    icon: Icons.play_circle_rounded,
                  ),
                  SizedBox(height: 16.h),
                  EmptyStateCard(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  ),
                ],
              );
            }

            final videos = snapshot.data ?? [];

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
              itemCount: videos.isEmpty ? 2 : videos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const SectionTitle(
                      title: 'YouTube Videos',
                      subtitle: 'Latest videos added by Admin',
                      icon: Icons.play_circle_rounded,
                    ),
                  );
                }

                if (videos.isEmpty) {
                  return const EmptyStateCard(
                    message:
                        'No YouTube videos found. Add videos from the Admin Panel.',
                  );
                }

                final video = videos[index - 1];
                final id = YoutubeUtils.extractVideoId(video.youtubeUrl);
                final thumb =
                    id != null ? YoutubeUtils.thumbnailUrl(id) : '';

                return Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _VideoCard(
                    title: video.title,
                    subtitle: (video.description ?? '').trim().isEmpty
                        ? 'Shree Chitragupt Peeth'
                        : video.description!,
                    thumbnailUrl: thumb,
                    onTap: () => _openVideo(video),
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

class YoutubeVideoPlayerScreen extends StatefulWidget {
  const YoutubeVideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  final String videoId;
  final String title;

  @override
  State<YoutubeVideoPlayerScreen> createState() =>
      _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.goldLight,
        onEnded: (_) => _controller.pause(),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              player,
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String thumbnailUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.105),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl.isEmpty)
                    Container(
                      height: 82.h,
                      width: 116.w,
                      color: AppColors.saffron.withOpacity(0.8),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36.sp,
                      ),
                    )
                  else
                    Image.network(
                      thumbnailUrl,
                      height: 82.h,
                      width: 116.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 82.h,
                          width: 116.w,
                          color: AppColors.saffron.withOpacity(0.8),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36.sp,
                          ),
                        );
                      },
                    ),
                  Container(
                    height: 38.w,
                    width: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
