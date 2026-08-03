import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class NewsLinksScreen extends StatefulWidget {
  const NewsLinksScreen({super.key});

  @override
  State<NewsLinksScreen> createState() => _NewsLinksScreenState();
}

class _NewsLinksScreenState extends State<NewsLinksScreen> {
  final _service = ContentService();
  late Future<List<NewsLinkItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchNewsLinks();
  }

  Future<void> _reload() async {
    setState(() => _future = _service.fetchNewsLinks());
    await _future;
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: FutureBuilder<List<NewsLinkItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingCard();
            }
            if (snapshot.hasError) {
              return ListView(
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
                children: [
                  const SectionTitle(
                    title: 'News Links',
                    subtitle: 'Latest news & media links',
                    icon: Icons.link_rounded,
                  ),
                  SizedBox(height: 20.h),
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
                      title: 'News Links',
                      subtitle: 'Latest news & media links',
                      icon: Icons.link_rounded,
                    ),
                  );
                }
                if (items.isEmpty) {
                  return const EmptyStateCard(
                    message: 'No news links available yet.',
                  );
                }
                final item = items[index - 1];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () => _open(item.url),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: AppColors.goldLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.open_in_new_rounded,
                              color: AppColors.goldLight,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if ((item.description ?? '').isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
