import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_actions.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class NewsImagesScreen extends StatefulWidget {
  const NewsImagesScreen({super.key});

  @override
  State<NewsImagesScreen> createState() => _NewsImagesScreenState();
}

class _NewsImagesScreenState extends State<NewsImagesScreen>
    with WidgetsBindingObserver {
  final _service = ContentService();
  late Future<List<NewsImageItem>> _future;
  int _fetchEpoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _service.fetchNewsImages();
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
      _future = _service.fetchNewsImages();
    });
    await _future;
  }

  Future<void> _reload() => reload();

  String _imageUrl(NewsImageItem item) {
    var url = ApiConfig.newsImage(item.imageFilename);
    if (url.isEmpty) return '';
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}_v=$_fetchEpoch';
  }

  void _openFullscreen(NewsImageItem item) {
    final rawUrl = ApiConfig.newsImage(item.imageFilename);
    if (rawUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImageScreen(
          imageUrl: rawUrl,
          description: item.description,
        ),
      ),
    );
  }

  Future<void> _download(NewsImageItem item) async {
    final rawUrl = ApiConfig.newsImage(item.imageFilename);
    if (rawUrl.isEmpty) return;
    await MediaActions.downloadImage(
      context,
      rawUrl,
      name:
          'news_image_${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: FutureBuilder<List<NewsImageItem>>(
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
                    title: 'News Images',
                    subtitle: 'Photo news from Admin Panel',
                    icon: Icons.photo_outlined,
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
                      title: 'News Images',
                      subtitle: 'Photo news from Admin Panel',
                      icon: Icons.photo_outlined,
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(18.w),
                      child: const EmptyStateCard(
                        message: 'No news images yet.',
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
                          final displayUrl = _imageUrl(item);
                          return _NewsImageTile(
                            displayUrl: displayUrl,
                            description: item.description,
                            onPreviewTap: () => _openFullscreen(item),
                            onDownloadTap: () => _download(item),
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

class _NewsImageTile extends StatelessWidget {
  const _NewsImageTile({
    required this.displayUrl,
    required this.onPreviewTap,
    required this.onDownloadTap,
    this.description,
  });

  final String displayUrl;
  final String? description;
  final VoidCallback onPreviewTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
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
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.white38),
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
                      if ((description ?? '').isNotEmpty)
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
          Positioned(
            top: 6.w,
            right: 6.w,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onDownloadTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.download_rounded,
                    size: 16.sp,
                    color: AppColors.goldLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenImageScreen extends StatelessWidget {
  const _FullscreenImageScreen({
    required this.imageUrl,
    this.description,
  });

  final String imageUrl;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Preview',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Preview / Fullscreen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ImmersiveViewer(imageUrl: imageUrl),
                ),
              );
            },
            icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: () {
              MediaActions.downloadImage(
                context,
                imageUrl,
                name: 'news_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
            },
            icon: const Icon(Icons.download_rounded, color: Colors.white),
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
          if ((description ?? '').isNotEmpty)
            Container(
              color: Colors.black87,
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.preview_rounded,
                          size: 16.sp, color: AppColors.goldLight),
                      SizedBox(width: 6.w),
                      Text(
                        'Caption',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.black87,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.fullscreen_rounded,
                    label: 'Preview',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _ImmersiveViewer(imageUrl: imageUrl),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onTap: () {
                      MediaActions.downloadImage(
                        context,
                        imageUrl,
                        name:
                            'news_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      );
                    },
                    highlighted: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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

class _ImmersiveViewer extends StatelessWidget {
  const _ImmersiveViewer({required this.imageUrl});

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
