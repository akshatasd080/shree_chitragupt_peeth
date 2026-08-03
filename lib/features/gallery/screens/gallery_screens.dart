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

class _GalleryImagesScreenState extends State<GalleryImagesScreen> {
  final _service = ContentService();
  late Future<List<GalleryImageItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchGalleryImages();
  }

  Future<void> _reload() async {
    setState(() => _future = _service.fetchGalleryImages());
    await _future;
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
                          final url =
                              ApiConfig.galleryImage(item.imageFilename);
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
                                  child: url.isEmpty
                                      ? const Icon(Icons.image,
                                          color: Colors.white38)
                                      : CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.broken_image,
                                                  color: Colors.white38),
                                        ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class GalleryVideosScreen extends StatefulWidget {
  const GalleryVideosScreen({super.key});

  @override
  State<GalleryVideosScreen> createState() => _GalleryVideosScreenState();
}

class _GalleryVideosScreenState extends State<GalleryVideosScreen> {
  final _service = ContentService();
  late Future<List<GalleryVideoItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchGalleryVideos();
  }

  Future<void> _reload() async {
    setState(() => _future = _service.fetchGalleryVideos());
    await _future;
  }

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
                final thumb = id != null ? YoutubeUtils.thumbnailUrl(id) : null;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () => _open(item),
                    borderRadius: BorderRadius.circular(16.r),
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
                            Stack(
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
                              ],
                            ),
                          Padding(
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
                        ],
                      ),
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
