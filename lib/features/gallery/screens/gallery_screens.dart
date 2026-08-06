import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_utils.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';
import '../../videos/screens/videos_screen.dart';

class GalleryImagesScreen extends StatefulWidget {
  const GalleryImagesScreen({super.key});

  @override
  State<GalleryImagesScreen> createState() => _GalleryImagesScreenState();
}

class _GalleryImagesScreenState extends State<GalleryImagesScreen>
    with WidgetsBindingObserver {
  final _service = ContentService();
  late Future<List<GalleryImageItem>> _future;
  int _fetchEpoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _service.fetchGalleryImages();
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
      _fetchEpoch = DateTime.now().millisecondsSinceEpoch;
      _future = _service.fetchGalleryImages();
    });
    await _future;
  }

  Future<void> _reload() => reload();

  String _displayUrl(String rawUrl) {
    var url = rawUrl;
    if (url.isEmpty) return '';
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}_v=$_fetchEpoch';
  }

  void _openFullscreen(GalleryImageItem item) {
    final rawUrl = ApiConfig.galleryImage(item.imageFilename);
    if (rawUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GalleryFullscreenImageScreen(
          imageUrl: rawUrl,
          title: item.title,
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
        child: FutureBuilder<List<GalleryImageItem>>(
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
                    title: 'Gallery Images',
                    subtitle: 'Temple photo gallery',
                    icon: Icons.photo_library_outlined,
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
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 12.h),
                    child: const SectionTitle(
                      title: 'Gallery Images',
                      subtitle: 'Temple photo gallery',
                      icon: Icons.photo_library_outlined,
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(18.w),
                      child: const EmptyStateCard(
                        message: 'No gallery images yet.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 40.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          final rawUrl =
                              ApiConfig.galleryImage(item.imageFilename);
                          final displayUrl = _displayUrl(rawUrl);
                          return _GalleryImageTile(
                            displayUrl: displayUrl,
                            title: item.title,
                            onPreviewTap: () => _openFullscreen(item),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GalleryImageTile extends StatelessWidget {
  const _GalleryImageTile({
    required this.displayUrl,
    required this.title,
    required this.onPreviewTap,
  });

  final String displayUrl;
  final String title;
  final VoidCallback onPreviewTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: onPreviewTap,
              child: displayUrl.isEmpty
                  ? const Icon(Icons.image, color: Colors.white38)
                  : CachedNetworkImage(
                      imageUrl: displayUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white38),
                    ),
            ),
          ),
          InkWell(
            onTap: onPreviewTap,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.zoom_out_map_rounded,
                        size: 12.sp,
                        color: AppColors.goldLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Preview',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class _GalleryFullscreenImageScreen extends StatelessWidget {
  const _GalleryFullscreenImageScreen({
    required this.imageUrl,
    required this.title,
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Fullscreen Preview',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _GalleryImmersiveViewer(imageUrl: imageUrl),
                ),
              );
            },
            icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.goldLight),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black87,
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            color: Colors.black87,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: SizedBox(
              width: double.infinity,
              child: _GalleryActionButton(
                icon: Icons.fullscreen_rounded,
                label: 'Preview',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _GalleryImmersiveViewer(imageUrl: imageUrl),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryActionButton extends StatelessWidget {
  const _GalleryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? AppColors.goldLight : Colors.white12;
    final fg = highlighted ? Colors.black : AppColors.goldLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: highlighted ? AppColors.goldLight : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: fg),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryImmersiveViewer extends StatelessWidget {
  const _GalleryImmersiveViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 10,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.goldLight),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20.h,
              left: 12.w,
              child: SafeArea(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_out_map_rounded,
                          size: 16.sp, color: Colors.white70),
                      SizedBox(width: 6.w),
                      Text(
                        'Pinch to zoom · Tap to close',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
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

class GalleryVideosScreen extends StatefulWidget {
  const GalleryVideosScreen({super.key});

  @override
  State<GalleryVideosScreen> createState() => _GalleryVideosScreenState();
}

class _GalleryVideosScreenState extends State<GalleryVideosScreen>
    with WidgetsBindingObserver {
  final _service = ContentService();
  late Future<List<GalleryVideoItem>> _future;
  int _fetchEpoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _service.fetchGalleryVideos();
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
      _fetchEpoch = DateTime.now().millisecondsSinceEpoch;
      _future = _service.fetchGalleryVideos();
    });
    await _future;
  }

  Future<void> _reload() => reload();

  void _open(GalleryVideoItem item) {
    final id = YoutubeUtils.extractVideoId(item.youtubeUrl);
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoPlayerScreen(
          videoId: id,
          title: item.title,
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
        child: FutureBuilder<List<GalleryVideoItem>>(
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
                    title: 'Gallery Videos',
                    subtitle: 'Video gallery from admin',
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
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SectionTitle(
                      title: 'Gallery Videos',
                      subtitle: 'Video gallery from admin',
                      icon: Icons.videocam_outlined,
                    ),
                  );
                }
                if (items.isEmpty) {
                  return const EmptyStateCard(
                    message: 'No gallery videos yet.',
                  );
                }
                final item = items[index - 1];
                final id = YoutubeUtils.extractVideoId(item.youtubeUrl);
                var thumb = id != null ? YoutubeUtils.thumbnailUrl(id) : null;
                if (thumb != null) {
                  final sep = thumb.contains('?') ? '&' : '?';
                  thumb = '$thumb${sep}_v=$_fetchEpoch';
                }

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
                        if (thumb != null)
                          InkWell(
                            onTap: () => _open(item),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: thumb,
                                  height: 170.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 54.sp,
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
                                          'Watch',
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
                              ],
                            ),
                          ),
                        InkWell(
                          onTap: () => _open(item),
                          child: Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                              ),
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
