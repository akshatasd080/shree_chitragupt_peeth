import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../contact/screens/contact_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'श्री चित्रगुप्त पीठ',
    'आरती',
    'Videos',
    'Contact',
    'Profile',
  ];

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link open nahi ho paaya.')),
      );
    }
  }

  Future<void> _openDonatePage() async {
    await _openUrl('https://www.shreechitraguptpeeth.org/donation');
  }

  @override
  Widget build(BuildContext context) {
    final bool showDonateButton = _currentIndex == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF090400),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: AppColors.goldLight,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.20),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.saffron.withOpacity(0.95),
                Colors.black.withOpacity(0.10),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          const _AartiTab(),
          const _VideosTab(),
          const ContactScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: showDonateButton
          ? Padding(
              padding: EdgeInsets.only(bottom: 12.h, right: 6.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.saffron,
                      AppColors.gold,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.saffron.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: 'donateButton',
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Donate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: _openDonatePage,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: AppColors.goldLight.withOpacity(0.18),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.goldLight,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 11.sp,
            unselectedFontSize: 10.sp,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book_rounded),
                label: 'Aarti',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline),
                activeIcon: Icon(Icons.play_circle_rounded),
                label: 'Videos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                activeIcon: Icon(Icons.location_on_rounded),
                label: 'Contact',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({required this.onTabChange});

  final void Function(int index) onTabChange;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _showKnowMore = false;

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 110.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHero(
              isExpanded: _showKnowMore,
              onKnowMoreTap: () {
                setState(() {
                  _showKnowMore = !_showKnowMore;
                });
              },
              onContactTap: () => widget.onTabChange(3),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: _showKnowMore
                  ? Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: const _WhoIsChitraguptSection(),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: 26.h),

            const _StatsGrid(),
            SizedBox(height: 28.h),

            const _CreamSection(
              label: 'ABOUT US',
              title: 'श्री चित्रगुप्त पीठ की स्थापना',
              text:
                  'समस्त प्राणियों को उनके कर्मों के आधार पर फल देने वाले देवता — बुद्धि विधाता, लेखनी दाता, धर्मराज भगवान श्री चित्रगुप्त जी की संसार में प्रथम शक्तिपीठ वृंदावन में स्थापित हो रही है।\n\nसम्पूर्ण भारत में भगवान श्री चित्रगुप्त जी के बहुत से मंदिर हैं, परंतु उनके बारे में सभी जानकारी एक स्थान से प्राप्त हो — इसी उद्देश्य से श्री चित्रगुप्त पीठ की स्थापना की गई है।',
            ),

            SizedBox(height: 26.h),

            const _SectionTitle(
              title: 'Quick Access',
              subtitle: 'Tap to open app sections',
              icon: Icons.grid_view_rounded,
            ),
            SizedBox(height: 14.h),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.18,
              children: [
                _QuickActionCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Aarti',
                  subtitle: 'Daily prayer',
                  onTap: () => widget.onTabChange(1),
                ),
                _QuickActionCard(
                  icon: Icons.play_circle_rounded,
                  title: 'Videos',
                  subtitle: 'YouTube content',
                  onTap: () => widget.onTabChange(2),
                ),
                _QuickActionCard(
                  icon: Icons.location_on_rounded,
                  title: 'Contact',
                  subtitle: 'Location & phone',
                  onTap: () => widget.onTabChange(3),
                ),
                _QuickActionCard(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'User details',
                  onTap: () => widget.onTabChange(4),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            const _CreamFeatureSection(),

            SizedBox(height: 30.h),

            const _MissionSection(),

            SizedBox(height: 30.h),

            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        gradient: LinearGradient(
          colors: [
            AppColors.saffron.withOpacity(0.94),
            AppColors.gold.withOpacity(0.74),
            const Color(0xFF4A1600).withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withOpacity(0.30),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 66.w,
            width: 66.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
              ),
            ),
            child: Icon(
              Icons.temple_hindu_rounded,
              color: Colors.white,
              size: 36.sp,
            ),
          ),
          SizedBox(height: 22.h),

          Text(
            'श्री चित्रगुप्त पीठ वृंदावन',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            'World\'s First Chitragupt Peeth · Vrindavan, UP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              height: 1.45,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            'संसार की प्रथम श्री चित्रगुप्त पीठ — वृंदावन में भव्य रूप से स्थापित हो रही है। बुद्धि विधाता, लेखनी दाता, धर्मराज भगवान श्री चित्रगुप्त जी की कृपा से एक दिव्य तीर्थ की स्थापना।',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 14.sp,
              height: 1.75,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 22.h),

          Row(
            children: [
              Expanded(
                child: _HeroButton(
                  text: isExpanded ? 'कम करें ↑' : 'जानें और / Know More',
                  filled: true,
                  onTap: onKnowMoreTap,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _HeroButton(
                  text: '💬 संपर्क करें',
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
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? Colors.white : Colors.transparent,
          side: BorderSide(
            color: Colors.white.withOpacity(0.9),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? AppColors.saffron : Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
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
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.96),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHO IS CHITRAGUPT',
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 12.sp,
              letterSpacing: 4,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'भगवान श्री चित्रगुप्त जी का परिचय',
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 4.h,
            width: 75.w,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'भगवान श्री चित्रगुप्त जी — बुद्धि विधाता, लेखनी दाता, समस्त ग्रह-नक्षत्रों के स्वामी हैं। वे संसार के समस्त प्राणियों के कर्मों का लेखा-जोखा रखते हैं और उनके कर्मों के आधार पर फल प्रदान करते हैं।\n\nहिंदू पुराणों के अनुसार, ब्रह्मा जी ने 11,000 वर्षों की गहन साधना के बाद अपनी काया से भगवान श्री चित्रगुप्त जी को प्रकट किया। इसलिए वे कायस्थ समुदाय के आदि पूर्वज और ईष्ट देव माने जाते हैं।\n\nवे हाथ में कलम, दवात और पुस्तक धारण करते हैं। न्याय के देवता यमराज की सहायता से वे सभी जीवों के पाप-पुण्य का हिसाब रखते हैं। उनकी आराधना से बुद्धि, विद्या और धर्म की प्राप्ति होती है।',
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 15.sp,
              height: 1.9,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 22.h),

          const _ChitraguptInfoCard(
            icon: '🖊️',
            title: 'लेखनी दाता',
            text: 'विद्या, बुद्धि और कलम के देवता — ज्ञान के प्रदाता।',
          ),
          SizedBox(height: 12.h),

          const _ChitraguptInfoCard(
            icon: '⚖️',
            title: 'कर्म के न्यायाधीश',
            text: 'समस्त प्राणियों के कर्मों का सटीक लेखा-जोखा रखते हैं।',
          ),
          SizedBox(height: 12.h),

          const _ChitraguptInfoCard(
            icon: '🌟',
            title: 'ग्रह-नक्षत्र स्वामी',
            text: 'समस्त ग्रहों और नक्षत्रों के अधिपति देवता।',
          ),
          SizedBox(height: 12.h),

          const _ChitraguptInfoCard(
            icon: '🙏',
            title: 'कायस्थ कुलदेव',
            text: 'कायस्थ समुदाय के आदि पूर्वज और परम ईष्ट देव।',
          ),
        ],
      ),
    );
  }
}

class _ChitraguptInfoCard extends StatelessWidget {
  const _ChitraguptInfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(
            color: AppColors.saffron,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 24.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF7A1E1E),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFF6E5738),
                    fontSize: 13.sp,
                    height: 1.5,
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.65,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        children: const [
          _StatItem(value: '1 करोड़+', label: 'मंत्र लेखन'),
          _StatItem(value: '3', label: 'तल्लीय मंदिर'),
          _StatItem(value: '2023', label: 'भूमि पूजन'),
          _StatItem(value: 'अखिल', label: 'भारतीय संस्था'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.goldLight,
            fontSize: 23.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
      ],
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
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.94),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 12.sp,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 4.h,
            width: 75.w,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 15.sp,
              height: 1.85,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreamFeatureSection extends StatelessWidget {
  const _CreamFeatureSection();

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData('🛕', 'तीन तल्लीय मंदिर', 'भव्य तीन मंजिला मंदिर का निर्माण — प्रभु के दिव्य दर्शन के लिए।'),
      _FeatureData('💧', 'जल परिक्रमा', 'जल के साथ पवित्र परिक्रमा पथ — आत्मशुद्धि का माध्यम।'),
      _FeatureData('🌸', 'नक्षत्र वाटिका', '27 नक्षत्रों के अनुसार वृक्षों की वाटिका — प्राकृतिक आरोग्य केंद्र।'),
      _FeatureData('📖', 'गुरुकुल विद्यापीठ', 'वैदिक शिक्षा, संस्कृत और सनातन परंपरा का केंद्र।'),
      _FeatureData('🏠', 'घर आँगन', 'बुजुर्ग माता-पिता के लिए आवासीय परिसर।'),
      _FeatureData('🛏️', 'श्री चित्रगुप्त निवास', 'अतिथि गृह एवं भोजनालय की सुविधा।'),
      _FeatureData('🌿', 'आयुर्वेदिक औषधालय', 'पंचकर्म एवं आयुर्वेदिक चिकित्सा सेवा।'),
      _FeatureData('🧘', 'ध्यान केंद्र', 'योग, प्राणायाम और ध्यान साधना का स्थान।'),
      _FeatureData('✍️', 'मंत्र लेखन बैंक', 'चित्रगुप्त मंत्र लेखन एवं शोध-चिंतन संस्थान।'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1CF).withOpacity(0.95),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPLORE',
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 12.sp,
              letterSpacing: 5,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'पीठ की विशेषताएँ',
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 4.h,
            width: 72.w,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          ...features.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _WhiteFeatureCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final String icon;
  final String title;
  final String text;

  _FeatureData(this.icon, this.title, this.text);
}

class _WhiteFeatureCard extends StatelessWidget {
  const _WhiteFeatureCard({required this.item});

  final _FeatureData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22.r),
        border: Border(
          top: BorderSide(
            color: AppColors.saffron,
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            item.icon,
            style: TextStyle(fontSize: 34.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6E5738),
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final missions = [
      _MissionData('01', 'महिमा प्रचार', 'भगवान श्री चित्रगुप्त जी की महिमा का वर्णन और प्रचार-प्रसार करना।'),
      _MissionData('02', 'गुरुकुल परंपरा', 'भारतीय वैदिक सनातनी गुरुकुल परंपरा को पुनः स्थापित करना।'),
      _MissionData('03', 'धर्म रक्षा', 'सनातन धर्म का प्रचार कर धर्म की रक्षा एवं राष्ट्र को सशक्त बनाना।'),
      _MissionData('04', 'प्रामाणिक जानकारी', 'वेद और पुराणों पर आधारित सटीक एवं प्रामाणिक जानकारी देना।'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xFF240800).withOpacity(0.90),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR MISSION',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 12.sp,
              letterSpacing: 5,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'हमारा उद्देश्य',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 4.h,
            width: 72.w,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          ...missions.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _MissionCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionData {
  final String number;
  final String title;
  final String text;

  _MissionData(this.number, this.title, this.text);
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.item});

  final _MissionData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1309).withOpacity(0.76),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.number,
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 30.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.title,
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            item.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 13.sp,
              height: 1.65,
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
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🕉️ SHREE CHITRAGUPT PEETH',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'सम्पूर्ण भारत में भगवान श्री चित्रगुप्त जी के बहुत से मंदिर हैं, परंतु उनके बारे में सभी जानकारी एक स्थान से प्राप्त हो — इसी उद्देश्य से श्री चित्रगुप्त पीठ की स्थापना की गई है।',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              height: 1.7,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '📞 +91-7065013874',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '✉️ shreechitraguptpeeth@gmail.com',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _AartiTab extends StatelessWidget {
  const _AartiTab();

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: 'भगवान चित्रगुप्त जी की आरती',
              subtitle: 'Daily prayer',
              icon: Icons.menu_book_rounded,
            ),
            SizedBox(height: 12.h),
            const _InfoCard(
              text:
                  'ॐ जय चित्रगुप्त हरे,\n'
                  'स्वामी जय चित्रगुप्त हरे।\n'
                  'भक्त जनों के संकट,\n'
                  'क्षण में दूर करे॥\n\n'
                  'जय देव जय देव,\n'
                  'श्री चित्रगुप्त देवा।\n'
                  'सुख संपत्ति दाता,\n'
                  'सबके भाग्य विधाता॥\n\n'
                  'हे प्रभु चित्रगुप्त भगवान,\n'
                  'हम सब पर अपनी कृपा बनाए रखें।',
            ),
          ],
        ),
      ),
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab();

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: 'YouTube Videos',
              subtitle: 'Bhajan, Aarti & Updates',
              icon: Icons.play_circle_rounded,
            ),
            SizedBox(height: 12.h),
            const _VideoCard(
              title: 'Shree Chitragupt Peeth Video 1',
              subtitle: 'YouTube video player yaha add hoga',
            ),
            SizedBox(height: 12.h),
            const _VideoCard(
              title: 'Shree Chitragupt Peeth Video 2',
              subtitle: 'youtube_player_flutter package use karenge',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: 'My Profile',
              subtitle: 'Welcome devotee',
              icon: Icons.person_rounded,
            ),
            SizedBox(height: 20.h),
            Center(
              child: Container(
                height: 108.w,
                width: 108.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.saffron,
                      AppColors.gold,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Center(
              child: Text(
                'जय श्री चित्रगुप्त जी की जय 🙏',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Welcome to Shree Chitragupt Peeth App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            const _ContactCard(
              icon: Icons.person_outline_rounded,
              title: 'Name',
              value: 'Guest User',
            ),
            SizedBox(height: 12.h),
            const _ContactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'user@example.com',
            ),
            SizedBox(height: 12.h),
            const _ContactCard(
              icon: Icons.phone_outlined,
              title: 'Mobile',
              value: '+91 XXXXX XXXXX',
            ),
            SizedBox(height: 12.h),
            const _ContactCard(
              icon: Icons.verified_user_outlined,
              title: 'Account Type',
              value: 'Devotee Account',
            ),
            SizedBox(height: 22.h),
            _ProfileActionButton(
              icon: Icons.edit_rounded,
              title: 'Edit Profile',
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _ProfileActionButton(
              icon: Icons.logout_rounded,
              title: 'Logout',
              isLogout: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            HomeScreen._bgImage,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.70),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.25),
                  const Color(0xFF2B0D00).withOpacity(0.55),
                  Colors.black.withOpacity(0.90),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48.w,
          width: 48.w,
          decoration: BoxDecoration(
            color: AppColors.goldLight.withOpacity(0.14),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            icon,
            color: AppColors.goldLight,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.88),
          fontSize: 14.sp,
          height: 1.75,
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppColors.goldLight,
                size: 30.sp,
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            height: 76.h,
            width: 96.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.saffron.withOpacity(0.95),
                  AppColors.gold.withOpacity(0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 42.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.sp,
                    height: 1.4,
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.goldLight,
            size: 25.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13.sp,
                    height: 1.45,
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

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              isLogout ? Colors.redAccent.withOpacity(0.88) : AppColors.saffron,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 22.sp,
        ),
        label: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.105),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}