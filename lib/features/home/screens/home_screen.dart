import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_utils.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/page_background.dart';
import '../../aarti/screens/aarti_screen.dart';
import '../../auth/screens/login_screen.dart';
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

  Future<void> _logout() async {
    await AuthService.clearAuthData();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
    final safeIndex = _currentIndex.clamp(0, _pages.length - 1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF090400),
        drawer: AppDrawer(
          selectedIndex: safeIndex,
          onSelect: _onSelect,
          onLogout: _logout,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: safeIndex,
                children: _pages,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _StickyTopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed menu + logo bar — stays on top while page content scrolls beneath.
class _StickyTopBar extends StatelessWidget {
  const _StickyTopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.35),
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.82),
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.08),
            ],
            stops: const [0.0, 0.72, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 10.h),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
                onPressed: onMenuTap,
              ),
              const Spacer(),
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  width: 36.w,
                  height: 36.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.temple_hindu_rounded,
                    color: Colors.white70,
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 36.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading) const LoadingCard(),
              if (_error != null && !_loading)
                EmptyStateCard(message: _error!, onRetry: _load),

              // HREP / hero carousel first
              if (!_loading) ...[
                SizedBox(height: 18.h),
                _HeroCarousel(
                  slides: _slides,
                  index: _slideIndex,
                  onChanged: (i) => setState(() => _slideIndex = i),
                ),
              ],

              // Daily Thought — right below hero, fetched from backend daily
              if (!_loading && _thought != null) ...[
                SizedBox(height: 18.h),
                _DailyThoughtHomeCard(
                  thought: _thought!,
                  onSeeAll: () => widget.onOpenDrawerItem(6),
                ),
              ],

              // Brand intro with Know More button
              SizedBox(height: 18.h),
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
                        padding: EdgeInsets.only(top: 14.h),
                        child: const _WhoIsChitraguptSection(),
                      )
                    : const SizedBox.shrink(),
              ),

              // About Us section
              SizedBox(height: 24.h),
              const _CreamSection(
                label: 'ABOUT US',
                title: 'श्री चित्रगुप्त पीठ की स्थापना',
                text:
                    'समस्त प्राणियों को उनके कर्मों के आधार पर फल देने वाले देवता बुद्धि विधाता लेखनी दाता समस्त गृह नक्षत्रों के स्वामी धमराज भगवान श्री चित्रगुप्त की समस्त भूमंडल पर धार्मिक आध्यात्मिक नगर श्री वृन्दावन गोवर्धन धाम मथुरा ब्रज प्रांत के ब्रज शांतिकूज आश्रम में संसार की प्रथम श्री चित्रगुप्त पीठ की स्थापना हो रही है। जिसका मुख्य उद्देश्य भगवान श्री चित्रगुप्त जी की महिमा का वर्णन करने के साथ-साथ भारतीय वैदिक सनातनी गुरुकुल परंपरा को सम्पूर्ण जगत में स्थापित कर सनातन धर्म का प्रचार प्रसार करना है    प्रभु की पीठ की स्थापना का संकल्प बाल्‍य काल में माता श्रीमति शांति देवी जो की माँ भगवती की परम भक्त थीं और उन्नाव जिले में अस्सी के दशक में चरण वाली माता के नाम से विख्यात थीं तथा पिता श्री बृज बहादुर सक्सैना की प्रेरणा से लिया जिसको पूर्ण करने के लिए गुप्त नवरात्रि मई 204 में हरिशचंद घाट काशी के प्रमुख एवं श्री सत्य नाथ मठ कादीपुर सुल्तानपुर के पीठाधीश्वर परमपूज्य गुरुदेव अवधूत श्री कपाली जी महाराज द्वारा गोविंदपुरम गाजियाबाद में प्रभु की मूर्ति की स्थापना कर शीघ्र ही संसार की प्रथम पीठ की स्थापना किसी दिव्य स्थान पर भव्य रूप से स्थापित करने का संकल्प परम पूज्य गुरुदेव कपाली जी महाराज के साथ काशी से पधारे विद्वानों एवं संत समाज द्वारा पूर्ण विधि विधान से श्री संजीव सक्सैना को यह संकल्प दिलवाया गया। साथ समस्त पुज्य संतों और विद्वानों द्वारा श्री संजीव सक्सैना को श्री चित्रगुप्त पीठ का पीठाधीश्वर नियुक्त किया गया।',
              ),

              // Pooja Seva
              SizedBox(height: 24.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SectionTitle(
                      title: 'Pooja Seva',
                      subtitle: 'Book temple seva',
                      icon: Icons.temple_hindu_rounded,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onOpenDrawerItem(9),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldLight,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text(
                      'Book',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
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

              // YouTube Videos (last)
              SizedBox(height: 24.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SectionTitle(
                      title: 'YouTube Videos',
                      subtitle: 'Latest darshan & pravachan',
                      icon: Icons.play_circle_rounded,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onOpenDrawerItem(1),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldLight,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
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
                  height: 168.h,
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

              SizedBox(height: 16.h),
              const _FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({
    required this.slides,
    required this.index,
    required this.onChanged,
  });

  final List<HeroSlide> slides;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(_HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.slides.length <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next =
          widget.index >= widget.slides.length - 1 ? 0 : widget.index + 1;
      widget.onChanged(next);
    });
  }

  void _goTo(int index) {
    widget.onChanged(index);
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    final index = widget.index;

    if (slides.isEmpty) {
      return Container(
        height: 168.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7A2F),
              Color(0xFFC9960C),
              Color(0xFF5A1A00),
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
              fontSize: 20.sp,
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
          borderRadius: BorderRadius.circular(20.r),
          child: SizedBox(
            height: 188.h,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14.w,
                  right: 14.w,
                  bottom: 14.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                      if ((slide.subtitle ?? '').isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          slide.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (slides.length > 1) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CarouselArrow(
                      icon: Icons.chevron_left_rounded,
                      onTap: () {
                        final next =
                            index == 0 ? slides.length - 1 : index - 1;
                        _goTo(next);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _CarouselArrow(
                      icon: Icons.chevron_right_rounded,
                      onTap: () {
                        final next =
                            index == slides.length - 1 ? 0 : index + 1;
                        _goTo(next);
                      },
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
              final active = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 18.w : 7.w,
                height: 7.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: active
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

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Material(
        color: Colors.black.withOpacity(0.28),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34.w,
            height: 34.w,
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
        ),
      ),
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
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF8A2B),
            Color(0xFFFF6B1A),
            Color(0xFFB84A08),
            Color(0xFF4A1600),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B1A).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'श्री चित्रगुप्त पीठ वृंदावन',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'भगवान श्री चित्रगुप्त जी की विश्व की प्रथम दिव्य पीठ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.45,
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
      height: 46.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? Colors.white : Colors.transparent,
          shadowColor: Colors.transparent,
          side: BorderSide(
            color: Colors.white.withOpacity(filled ? 0 : 0.9),
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? AppColors.saffron : Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DailyThoughtHomeCard extends StatefulWidget {
  const _DailyThoughtHomeCard({
    required this.thought,
    required this.onSeeAll,
  });

  final DailyThought thought;
  final VoidCallback onSeeAll;

  @override
  State<_DailyThoughtHomeCard> createState() => _DailyThoughtHomeCardState();
}

class _DailyThoughtHomeCardState extends State<_DailyThoughtHomeCard> {
  bool _showEnglish = false;

  String get _displayText {
    if (_showEnglish) {
      final en = widget.thought.thoughtEn?.trim() ?? '';
      if (en.isNotEmpty) return en;
    }
    return widget.thought.primaryText;
  }

  String? get _formattedDate {
    final raw = widget.thought.thoughtDate;
    if (raw == null || raw.isEmpty) return null;
    try {
      final date = DateTime.parse(raw);
      final locale = _showEnglish ? 'en_IN' : 'hi_IN';
      return DateFormat('d MMMM yyyy', locale).format(date);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.thoughtImage(widget.thought.imageFilename);
    final hasEnglish =
        (widget.thought.thoughtEn?.trim() ?? '').isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFF0DC),
            Color(0xFFFFE8CC),
          ],
        ),
        border: Border.all(color: AppColors.saffron.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: AppColors.saffron,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Thought',
                        style: TextStyle(
                          color: AppColors.saffron,
                          fontSize: 11.sp,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'आज का विचार',
                        style: TextStyle(
                          color: const Color(0xFF7A1E1E),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasEnglish)
                  Material(
                    color: AppColors.saffron,
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => setState(() => _showEnglish = !_showEnglish),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        child: Text(
                          _showEnglish ? 'हिंदी' : 'English',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (imageUrl.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“',
                      style: TextStyle(
                        color: AppColors.saffron.withOpacity(0.45),
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        _displayText,
                        style: TextStyle(
                          color: const Color(0xFF2D1A00),
                          fontSize: 15.sp,
                          height: 1.65,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_formattedDate != null) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12.sp,
                          color: AppColors.saffron,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formattedDate!,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: widget.onSeeAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.saffron,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    icon: Icon(Icons.arrow_forward_rounded, size: 16.sp),
                    label: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
        width: 200.w,
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
                      height: 112.h,
                      width: 200.w,
                      color: Colors.white12,
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      height: 112.h,
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withOpacity(0.95),
                      size: 26.sp,
                    ),
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
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                height: 1.3,
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
