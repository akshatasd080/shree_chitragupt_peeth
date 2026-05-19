import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _VideosScreenState extends State<VideosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late Future<List<Video>> _videosFuture;
  late Future<List<Video>> _shortsFuture;
  late Future<List<Video>> _liveFuture;
  late Future<List<Video>> _podcastFuture;

  final List<String> _tabs = const [
    'Videos',
    'Shorts',
    'Live',
    'Podcasts',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);

    _videosFuture = _loadChannelVideos();
    _shortsFuture = _searchVideos('Shree Chitragupt Peeth shorts');
    _liveFuture = _searchVideos('Shree Chitragupt Peeth live');
    _podcastFuture = _searchVideos('Shree Chitragupt Peeth podcast story katha');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Video>> _loadChannelVideos() async {
    final yt = YoutubeExplode();

    try {
      try {
        final channel = await yt.channels.getByHandle(
          'shreechitraguptpeeth3940',
        );

        final videos = await yt.channels
            .getUploads(channel.id)
            .take(100)
            .toList();

        if (videos.isNotEmpty) return videos;
      } catch (_) {}

      return _searchVideos('Shree Chitragupt Peeth latest videos');
    } finally {
      yt.close();
    }
  }

  Future<List<Video>> _searchVideos(String query) async {
    final yt = YoutubeExplode();

    try {
      final result = await yt.search.search(query);
      return result.whereType<Video>().take(100).toList();
    } finally {
      yt.close();
    }
  }

  Future<void> _refreshVideos() async {
    setState(() {
      _videosFuture = _loadChannelVideos();
      _shortsFuture = _searchVideos('Shree Chitragupt Peeth shorts');
      _liveFuture = _searchVideos('Shree Chitragupt Peeth live');
      _podcastFuture =
          _searchVideos('Shree Chitragupt Peeth podcast story katha');
    });
  }

  Future<List<Video>> _futureByTab(int index) {
    switch (index) {
      case 1:
        return _shortsFuture;
      case 2:
        return _liveFuture;
      case 3:
        return _podcastFuture;
      default:
        return _videosFuture;
    }
  }

  void _openVideo(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoPlayerScreen(
          videoId: video.id.value,
          title: video.title,
        ),
      ),
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

                Container(
                  height: 46.h,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    indicator: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),

                SizedBox(height: 16.h),

                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return FutureBuilder<List<Video>>(
                      future: _futureByTab(_tabController.index),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                'Videos load nahi ho paayi. Internet check karo aur refresh karo.',
                          );
                        }

                        final videos = snapshot.data ?? [];

                        if (videos.isEmpty) {
                          return _MessageBox(
                            text:
                                '${_tabs[_tabController.index]} section me video nahi mili.',
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
        onEnded: (_) {
          _controller.pause();
        },
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