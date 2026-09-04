import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  final _service = ContentService();
  late TabController _tabController;
  late Future<List<EventItem>> _upcoming;
  late Future<List<EventItem>> _past;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  void _load() {
    _upcoming = _service.fetchEvents(type: 'upcoming');
    _past = _service.fetchEvents(type: 'past');
  }

  Future<void> _reload() async {
    setState(_load);
    await Future.wait([_upcoming, _past]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 8.h),
            child: const SectionTitle(
              title: 'Events',
              subtitle: 'Temple events & gatherings',
              icon: Icons.event_rounded,
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.goldLight,
            labelColor: AppColors.goldLight,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EventsList(future: _upcoming, onRefresh: _reload),
                _EventsList(future: _past, onRefresh: _reload),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.future, required this.onRefresh});

  final Future<List<EventItem>> future;
  final Future<void> Function() onRefresh;

  void _openPreview(BuildContext context, EventItem event, String imageUrl) {
    EventImagePreviewScreen.open(context, event, imageUrl: imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.goldLight,
      onRefresh: onRefresh,
      child: FutureBuilder<List<EventItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingCard();
          }
          if (snapshot.hasError) {
            return ListView(
              padding: EdgeInsets.all(18.w),
              children: [
                EmptyStateCard(
                  message: snapshot.error.toString(),
                  onRetry: onRefresh,
                ),
              ],
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(18.w),
              children: const [
                EmptyStateCard(message: 'No events found.'),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 40.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final e = items[index];
              final imageUrl = ApiConfig.eventImage(e.imageFilename);
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: imageUrl.isEmpty
                        ? null
                        : () => _openPreview(context, e, imageUrl),
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
                          if (imageUrl.isNotEmpty)
                            Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 160.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 160.h,
                                    color: Colors.white10,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 160.h,
                                    color: Colors.white10,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white38),
                                  ),
                                ),
                                Positioned(
                                  right: 10.w,
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
                                          Icons.zoom_out_map_rounded,
                                          color: AppColors.goldLight,
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Preview',
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
                              ],
                            ),
                          Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if ((e.eventDate ?? '').isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    [
                                      e.eventDate,
                                      if ((e.eventTime ?? '').isNotEmpty)
                                        e.eventTime,
                                    ].whereType<String>().join(' · '),
                                    style: TextStyle(
                                      color: AppColors.goldLight,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                if ((e.location ?? '').isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    e.location!,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                                if ((e.description ?? '').isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    e.description!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EventImagePreviewScreen extends StatelessWidget {
  const EventImagePreviewScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    this.dateTime = '',
  });

  final String imageUrl;
  final String title;
  final String dateTime;

  static String dateTimeLabel(EventItem event) {
    return [
      event.eventDate,
      if ((event.eventTime ?? '').isNotEmpty) event.eventTime,
    ].whereType<String>().join(' · ');
  }

  static void open(
    BuildContext context,
    EventItem event, {
    String? imageUrl,
  }) {
    final url = imageUrl ?? ApiConfig.eventImage(event.imageFilename);
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventImagePreviewScreen(
          imageUrl: url,
          title: event.title,
          dateTime: dateTimeLabel(event),
        ),
      ),
    );
  }

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
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: SafeArea(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dateTime.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Text(
                            dateTime,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_out_map_rounded,
                              size: 16.sp,
                              color: Colors.white70,
                            ),
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
