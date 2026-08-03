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
              );
            },
          );
        },
      ),
    );
  }
}
