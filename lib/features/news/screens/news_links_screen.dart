import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class NewsLinksScreen extends StatefulWidget {
  const NewsLinksScreen({
    super.key,
    this.isActive = false,
  });

  /// Whether this tab is currently visible in the home shell.
  final bool isActive;

  @override
  State<NewsLinksScreen> createState() => _NewsLinksScreenState();
}

class _NewsLinksScreenState extends State<NewsLinksScreen>
    with WidgetsBindingObserver {
  final _service = ContentService();

  List<NewsLinkItem> _items = [];
  bool _loading = true;
  String? _error;
  bool _refreshing = false;

  Timer? _pollTimer;
  bool _appResumed = true;

  /// Fast poll while the News Links tab is open so Admin Panel adds show quickly.
  static const _activePollInterval = Duration(seconds: 5);
  static const _idlePollInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load(showLoader: true);
    _syncPolling();
  }

  @override
  void didUpdateWidget(covariant NewsLinksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Tab just opened — fetch immediately, then keep polling.
      _load(showLoader: false);
    }
    if (widget.isActive != oldWidget.isActive) {
      _syncPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    if (_appResumed) {
      if (widget.isActive) {
        _load(showLoader: false);
      }
      _syncPolling();
    } else {
      _stopPolling();
    }
  }

  void _syncPolling() {
    _stopPolling();
    if (!_appResumed) return;

    final interval =
        widget.isActive ? _activePollInterval : _idlePollInterval;
    _pollTimer = Timer.periodic(interval, (_) {
      if (!mounted || !_appResumed) return;
      _load(showLoader: false);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Public so HomeScreen can trigger a refresh when opening this tab.
  Future<void> reload() => _load(showLoader: _items.isEmpty);

  Future<void> _load({required bool showLoader}) async {
    if (_refreshing) return;
    _refreshing = true;

    if (showLoader && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final fresh = await _service.fetchNewsLinks();
      if (!mounted) return;

      final changed = _listsDiffer(_items, fresh);
      if (changed || _loading || _error != null) {
        setState(() {
          _items = fresh;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Keep showing existing items on silent refresh failures.
      if (_items.isEmpty || showLoader) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  static bool _listsDiffer(List<NewsLinkItem> a, List<NewsLinkItem> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].title != b[i].title ||
          a[i].url != b[i].url ||
          a[i].description != b[i].description ||
          a[i].linkType != b[i].linkType) {
        return true;
      }
    }
    return false;
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
        onRefresh: () => _load(showLoader: false),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const LoadingCard();
    }

    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
        children: [
          const SectionTitle(
            title: 'News Links',
            subtitle: 'Latest news & media links',
            icon: Icons.link_rounded,
          ),
          SizedBox(height: 20.h),
          EmptyStateCard(
            message: _error!,
            onRetry: () => _load(showLoader: true),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
      itemCount: _items.isEmpty ? 2 : _items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                const Expanded(
                  child: SectionTitle(
                    title: 'News Links',
                    subtitle: 'Latest news & media links',
                    icon: Icons.link_rounded,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Icon(
                    Icons.sync_rounded,
                    size: 18.sp,
                    color: AppColors.goldLight.withOpacity(0.8),
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (_items.isEmpty) {
          return const EmptyStateCard(
            message: 'No news links available yet.',
          );
        }
        final item = _items[index - 1];
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
  }
}
