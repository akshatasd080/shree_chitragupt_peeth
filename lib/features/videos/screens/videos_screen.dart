import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/constants/app_colors.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<List<Video>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadRecentVideos();
  }

  Future<List<Video>> _loadRecentVideos() async {
    final yt = YoutubeExplode();

    try {
      try {
        final channel = await yt.channels.getByHandle(
          'shreechitraguptpeeth3940',
        );

        final videos = await yt.channels
            .getUploads(channel.id)
            .take(15)
            .toList();

        if (videos.isNotEmpty) {
          return videos;
        }
      } catch (_) {
        // Fallback below
      }

      final searchResult = await yt.search.search('Shree Chitragupt Peeth');

      final searchVideos = searchResult.whereType<Video>().take(15).toList();

      return searchVideos;
    } finally {
      yt.close();
    }
  }

  Future<void> _refreshVideos() async {
    setState(() {
      _videosFuture = _loadRecentVideos();
    });

    await _videosFuture;
  }

  void _openVideo(Video video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) {
        return _YoutubePlayerSheet(
          videoId: video.id.value,
          title: video.title,
        );
      },
    );
  }

  String _thumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.goldLight,
          onRefresh: _refreshVideos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, 28.h, 18.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: 'YouTube Videos',
                  subtitle: 'Latest Bhajan, Aarti & Updates',
                  icon: Icons.play_circle_rounded,
                ),
                SizedBox(height: 16.h),
                FutureBuilder<List<Video>>(
                  future: _videosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.goldLight,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const _MessageBox(
                        text:
                            'Videos load nahi ho paayi. Internet connection check karo aur pull down karke refresh karo.',
                      );
                    }

                    final videos = snapshot.data ?? [];

                    if (videos.isEmpty) {
                      return const _MessageBox(
                        text: 'Abhi koi video available nahi hai.',
                      );
                    }

                    return Column(
                      children: videos.map((video) {
                        final videoId = video.id.value;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: _VideoCard(
                            title: video.title,
                            subtitle: video.author,
                            thumbnailUrl: _thumbnailUrl(videoId),
                            onTap: () => _openVideo(video),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YoutubePlayerSheet extends StatefulWidget {
  const _YoutubePlayerSheet({
    required this.videoId,
    required this.title,
  });

  final String videoId;
  final String title;

  @override
  State<_YoutubePlayerSheet> createState() => _YoutubePlayerSheetState();
}

class _YoutubePlayerSheetState extends State<_YoutubePlayerSheet> {
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.goldLight,
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              VideosScreen._bgImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.72)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.saffron.withOpacity(0.55),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldLight, size: 28.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                    maxLines: 1,
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

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 13.sp,
          height: 1.4,
        ),
      ),
    );
  }
}