import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_utils.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/page_background.dart';
import '../../aarti/screens/aarti_screen.dart';
import '../../contact/screens/contact_screen.dart';
import '../../daily_thought/screens/daily_thought_screen.dart';
import '../../donation/screens/donation_screen.dart';
import '../../events/screens/events_screen.dart';
import '../../gallery/screens/gallery_screens.dart';
import '../../member/screens/member_screen.dart';
import '../../news/screens/news_images_screen.dart';
import '../../news/screens/news_links_screen.dart';
import '../../news/screens/news_videos_screen.dart';
import '../../pooja/screens/pooja_booking_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../videos/screens/videos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final _newsImagesKey = GlobalKey(debugLabel: 'news_images');
  final _newsVideosKey = GlobalKey(debugLabel: 'news_videos');
  final _newsLinksKey = GlobalKey(debugLabel: 'news_links');
  final _galleryImagesKey = GlobalKey(debugLabel: 'gallery_images');
  final _galleryVideosKey = GlobalKey(debugLabel: 'gallery_videos');

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(onOpenDrawerItem: _onSelect),
      const VideosScreen(),
      NewsImagesScreen(key: _newsImagesKey),
      NewsVideosScreen(key: _newsVideosKey),
      NewsLinksScreen(key: _newsLinksKey),
      const EventsScreen(),
      const DailyThoughtScreen(),
      const ContactScreen(),
      const MemberScreen(),
      const PoojaBookingScreen(),
      const DonationScreen(),
      GalleryImagesScreen(key: _galleryImagesKey),
      GalleryVideosScreen(key: _galleryVideosKey),
      const AartiScreen(),
      const ProfileScreen(),
    ];
  }

  void _onSelect(int index) {
    setState(() => _currentIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (index) {
        case 2:
          _callReload(_newsImagesKey);
          break;
        case 3:
          _callReload(_newsVideosKey);
          break;
        case 4:
          _callReload(_newsLinksKey);
          break;
        case 11:
          _callReload(_galleryImagesKey);
          break;
        case 12:
          _callReload(_galleryVideosKey);
          break;
      }
    });
  }

  static void _callReload(GlobalKey key) {
    final state = key.currentState;
    if (state == null) return;
    try {
      // ignore: avoid_dynamic_calls
      (state as dynamic).reload();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = AppDrawer.items[_currentIndex].label;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF090400),
      drawer: AppDrawer(
        selectedIndex: _currentIndex,
        onSelect: _onSelect,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: 34.w,
                height: 34.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.temple_hindu_rounded,
                  color: Colors.white70,
                  size: 26.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}

/// Home dashboard — loads hero, thought, YouTube & poojas from backend.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onOpenDrawerItem});

  final ValueChanged<int> onOpenDrawerItem;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _service = ContentService();

  List<HeroSlide> _slides = [];
  DailyThought? _thought;
  List<YoutubeVideoItem> _videos = [];
  List<PoojaItem> _poojas = [];

  bool _loading = true;
  String? _error;
  int _slideIndex = 0;
  bool _showKnowMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.fetchHeroSlides(),
        _service.fetchTodayThought(),
        _service.fetchYoutubeVideos(latest: true, limit: 6),
        _service.fetchPoojas(),
      ]);

      if (!mounted) return;
      setState(() {
        _slides = results[0] as List<HeroSlide>;
        _thought = results[1] as DailyThought?;
        _videos = results[2] as List<YoutubeVideoItem>;
        _poojas = results[3] as List<PoojaItem>;
        _slideIndex = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _openYoutube(YoutubeVideoItem video) {
    final id = YoutubeUtils.extractVideoId(video.youtubeUrl);
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoPlayerScreen(
          videoId: id,
          title: video.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading) const LoadingCard(),
              if (_error != null && !_loading)
                EmptyStateCard(message: _error!, onRetry: _load),

              // Hero slides from admin
              if (!_loading) ...[
                _HeroCarousel(
                  slides: _slides,
                  index: _slideIndex,
                  onChanged: (i) => setState(() => _slideIndex = i),
                ),
                SizedBox(height: 20.h),
              ],

              // Intro (kept from existing design)
              _HomeIntroCard(
                isExpanded: _showKnowMore,
                onKnowMoreTap: () {
                  setState(() => _showKnowMore = !_showKnowMore);
                },
                onContactTap: () => widget.onOpenDrawerItem(7),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: _showKnowMore
                    ? Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: const _WhoIsChitraguptSection(),
                      )
                    : const SizedBox.shrink(),
              ),

              // Daily thought
              if (_thought != null) ...[
                SizedBox(height: 22.h),
                const SectionTitle(
                  title: 'Daily Thought',
                  subtitle: 'आज का विचार',
                  icon: Icons.lightbulb_outline_rounded,
                ),
                SizedBox(height: 12.h),
                _ThoughtCard(
                  thought: _thought!,
                  onSeeAll: () => widget.onOpenDrawerItem(4),
                ),
              ],

              // YouTube from admin
              SizedBox(height: 22.h),
              Row(
                children: [
                  const Expanded(
                    child: SectionTitle(
                      title: 'YouTube Videos',
                      subtitle: 'From Admin Panel',
                      icon: Icons.play_circle_rounded,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onOpenDrawerItem(1),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: AppColors.goldLight),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (_videos.isEmpty)
                const EmptyStateCard(
                  message: 'No YouTube videos yet. Add them in Admin Panel.',
                )
              else
                SizedBox(
                  height: 190.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _videos.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      final v = _videos[index];
                      final id = YoutubeUtils.extractVideoId(v.youtubeUrl);
                      final thumb =
                          id != null ? YoutubeUtils.thumbnailUrl(id) : '';
                      return _HomeVideoTile(
                        title: v.title,
                        thumbnailUrl: thumb,
                        onTap: () => _openYoutube(v),
                      );
                    },
                  ),
                ),

              // Poojas from admin
              SizedBox(height: 22.h),
              Row(
                children: [
                  const Expanded(
                    child: SectionTitle(
                      title: 'Pooja Seva',
                      subtitle: 'Active poojas from Admin',
                      icon: Icons.temple_hindu_rounded,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onOpenDrawerItem(9),
                    child: const Text(
                      'Book',
                      style: TextStyle(color: AppColors.goldLight),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (_poojas.isEmpty)
                const EmptyStateCard(
                  message: 'No poojas available yet.',
                )
              else
                ..._poojas.take(4).map(
                      (p) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _PoojaTile(pooja: p),
                      ),
                    ),

              // Quick access to drawer sections
              SizedBox(height: 22.h),
              const SectionTitle(
                title: 'Quick Access',
                subtitle: 'Open from menu',
                icon: Icons.grid_view_rounded,
              ),
              SizedBox(height: 12.h),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.35,
                children: [
                  _QuickCard(
                    icon: Icons.event_rounded,
                    title: 'Events',
                    onTap: () => widget.onOpenDrawerItem(5),
                  ),
                  _QuickCard(
                    icon: Icons.photo_library_outlined,
                    title: 'Gallery',
                    onTap: () => widget.onOpenDrawerItem(11),
                  ),
                  _QuickCard(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Donation',
                    onTap: () => widget.onOpenDrawerItem(10),
                  ),
                  _QuickCard(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Member',
                    onTap: () => widget.onOpenDrawerItem(8),
                  ),
                ],
              ),

              SizedBox(height: 24.h),
              const _CreamSection(
                label: 'ABOUT US',
                title: 'श्री चित्रगुप्त पीठ',
                text:
                    'श्री वृन्दावन धाम की पावन भूमि पर स्थापित श्री चित्रगुप्त पीठ भगवान श्री चित्रगुप्त जी की महिमा, सनातन धर्म के संरक्षण एवं भारतीय वैदिक संस्कृति के वैश्विक प्रचार-प्रसार हेतु समर्पित एक दिव्य आध्यात्मिक संस्थान है।',
              ),
              SizedBox(height: 20.h),
              const _FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.slides,
    required this.index,
    required this.onChanged,
  });

  final List<HeroSlide> slides;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (slides.isEmpty) {
      return Container(
        height: 190.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: LinearGradient(
            colors: [
              AppColors.saffron.withOpacity(0.9),
              AppColors.gold.withOpacity(0.7),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'श्री चित्रगुप्त पीठ वृंदावन',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    final slide = slides[index.clamp(0, slides.length - 1)];
    final imageUrl = ApiConfig.heroImage(slide.imageFilename);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: SizedBox(
            height: 200.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.saffron,
                    ),
                  )
                else
                  Container(color: AppColors.saffron),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((slide.subtitle ?? '').isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          slide.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (slides.length > 1) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        final next = index == 0 ? slides.length - 1 : index - 1;
                        onChanged(next);
                      },
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        final next = index == slides.length - 1 ? 0 : index + 1;
                        onChanged(next);
                      },
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (slides.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              return Container(
                width: i == index ? 18.w : 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: i == index
                      ? AppColors.goldLight
                      : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HomeIntroCard extends StatelessWidget {
  const _HomeIntroCard({
    required this.isExpanded,
    required this.onKnowMoreTap,
    required this.onContactTap,
  });

  final bool isExpanded;
  final VoidCallback onKnowMoreTap;
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            AppColors.saffron.withOpacity(0.94),
            AppColors.gold.withOpacity(0.74),
            const Color(0xFF4A1600).withOpacity(0.92),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'श्री चित्रगुप्त पीठ वृंदावन',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'भगवान श्री चित्रगुप्त जी की विश्व की प्रथम दिव्य पीठ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _HeroButton(
                  text: isExpanded ? 'कम करें ↑' : 'जानें / Know More',
                  filled: true,
                  onTap: onKnowMoreTap,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _HeroButton(
                  text: 'संपर्क करें',
                  filled: false,
                  onTap: onContactTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? Colors.white : Colors.transparent,
          side: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: filled ? AppColors.saffron : Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.thought, required this.onSeeAll});

  final DailyThought thought;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.95),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thought.primaryText,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 14.sp,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'View All',
                style: TextStyle(color: AppColors.saffron),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeVideoTile extends StatelessWidget {
  const _HomeVideoTile({
    required this.title,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String title;
  final String thumbnailUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 220.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl.isEmpty)
                    Container(
                      height: 120.h,
                      width: 220.w,
                      color: Colors.white12,
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      height: 120.h,
                      width: 220.w,
                      fit: BoxFit.cover,
                    ),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white.withOpacity(0.92),
                    size: 42.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoojaTile extends StatelessWidget {
  const _PoojaTile({required this.pooja});

  final PoojaItem pooja;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.poojaImage(pooja.imageFilename);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: imageUrl.isEmpty
                ? Container(
                    width: 64.w,
                    height: 64.w,
                    color: Colors.white12,
                    child:
                        const Icon(Icons.temple_hindu, color: Colors.white54),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 64.w,
                    height: 64.w,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pooja.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((pooja.day ?? '').isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    pooja.day == 'Everyday' ? 'Everyday' : 'Every ${pooja.day}',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.goldLight, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhoIsChitraguptSection extends StatelessWidget {
  const _WhoIsChitraguptSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.97),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHO IS CHITRAGUPT',
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 12.sp,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'भगवान श्री चित्रगुप्त जी का परिचय',
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'भगवान श्री चित्रगुप्त जी — बुद्धि विधाता, लेखनी दाता, समस्त ग्रह-नक्षत्रों के स्वामी हैं। वे संसार के समस्त प्राणियों के कर्मों का लेखा-जोखा रखते हैं और उनके कर्मों के आधार पर फल प्रदान करते हैं।',
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 14.sp,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreamSection extends StatelessWidget {
  const _CreamSection({
    required this.label,
    required this.title,
    required this.text,
  });

  final String label;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.94),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 12.sp,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 14.sp,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Shree Chitragupt Peeth',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '+91-7065013874  ·  shreechitraguptpeeth@gmail.com',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
