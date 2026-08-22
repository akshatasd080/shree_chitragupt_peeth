import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class DailyThoughtScreen extends StatefulWidget {
  const DailyThoughtScreen({super.key});

  @override
  State<DailyThoughtScreen> createState() => _DailyThoughtScreenState();
}

class _DailyThoughtScreenState extends State<DailyThoughtScreen> {
  final _service = ContentService();
  late Future<DailyThought?> _todayFuture;
  bool _showEnglish = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _todayFuture = _service.fetchTodayThought();
  }

  Future<void> _reload() async {
    setState(_load);
    await _todayFuture;
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
          children: [
            const SectionTitle(
              title: 'Daily Thought',
              subtitle: 'Today\'s spiritual message',
              icon: Icons.lightbulb_outline_rounded,
            ),
            SizedBox(height: 18.h),
            FutureBuilder<DailyThought?>(
              future: _todayFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingCard();
                }
                if (snapshot.hasError) {
                  return EmptyStateCard(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }
                final thought = snapshot.data;
                if (thought == null) {
                  return const EmptyStateCard(
                    message: 'No thought available for today.',
                  );
                }
                final text = _showEnglish
                    ? ((thought.thoughtEn ?? '').trim().isNotEmpty
                        ? thought.thoughtEn!
                        : thought.primaryText)
                    : thought.primaryText;
                final imageUrl = ApiConfig.thoughtImage(thought.imageFilename);

                return Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6DD).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 14.h),
                      ],
                      Text(
                        'आज का विचार',
                        style: TextStyle(
                          color: AppColors.saffron,
                          fontSize: 12.sp,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        text,
                        style: TextStyle(
                          color: const Color(0xFF2D1A00),
                          fontSize: 16.sp,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _showEnglish = !_showEnglish),
                          child: Text(
                            _showEnglish ? 'हिंदी' : 'English',
                            style: const TextStyle(color: AppColors.saffron),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
