import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../aarti/screens/aarti_screen.dart';
import '../../contact/screens/contact_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../videos/screens/videos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _openDonatePage() async {
    final uri = Uri.parse('https://www.shreechitraguptpeeth.org/donation');

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation page open nahi ho paaya.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDonateButton = _currentIndex == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF090400),
      extendBody: true,

      // Top AppBar/header removed. Baaki code same rakha hai.
      appBar: null,

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
          const AartiScreen(),
          const VideosScreen(),
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
            top: BorderSide(color: AppColors.goldLight.withOpacity(0.18)),
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
        padding: EdgeInsets.fromLTRB(18.w, 55.h, 18.w, 120.h),
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
              title: 'श्री चित्रगुप्त पीठ',
              text:
                  'श्री वृन्दावन धाम की पावन भूमि पर स्थापित श्री चित्रगुप्त पीठ भगवान श्री चित्रगुप्त जी की महिमा, सनातन धर्म के संरक्षण एवं भारतीय वैदिक संस्कृति के वैश्विक प्रचार-प्रसार हेतु समर्पित एक दिव्य आध्यात्मिक संस्थान है। यह पीठ धर्म, न्याय, संस्कार, सेवा, योग, शिक्षा एवं मानव कल्याण के माध्यम से समाज में आध्यात्मिक चेतना और नैतिक मूल्यों का जागरण करने के लिए निरंतर कार्यरत है।',
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
            'भगवान श्री चित्रगुप्त जी की चवश्व की प्रथम चिव्य पीठ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'वन्दावन धाम की पावन भूचम पर स्थाचपत हो रही श्री चित्रगुप्त पीठ भगवान श्री चित्रगुप्त जी को समचपित चवश्व की प्रथम आध्यात्मिक, साृंस्क चतक एवृं वैचदक पीठ है। यह के वल एक मृंचदर नहीृं, बत्मि धमि, न ् याय, चिक्षा, सृंस्कार, सेवा, योग, िोध एवृं मानव कल्याण का एक समग्र आध्यात्मिक कें द्र है, जहााँ सनातन सृंस्क चत की अमूल्य चवरासत को आने वाली पीच़ियोृं तक पहाँिाने का सृंकल्प चलया गया है।',
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
                  text: isExpanded ? 'कम करें ↑' : 'जानें / Know More',
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
      height: 54.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          backgroundColor: filled ? Colors.white : Colors.transparent,
          side: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? AppColors.saffron : Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
            ),
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
        color: const Color(0xFFFFF6DD).withOpacity(0.97),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
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
              fontWeight: FontWeight.w700,
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
          SizedBox(height: 22.h),
          Text(
            'भगवान श्री चित्रगुप्त जी — बुद्धि विधाता, लेखनी दाता, समस्त ग्रह-नक्षत्रों के स्वामी हैं। वे संसार के समस्त प्राणियों के कर्मों का लेखा-जोखा रखते हैं और उनके कर्मों के आधार पर फल प्रदान करते हैं।\n\n'
            'हिंदू पुराणों के अनुसार, ब्रह्मा जी ने 11,000 वर्षों की गहन साधना के बाद अपनी काया से भगवान श्री चित्रगुप्त जी को प्रकट किया। इसलिए वे कायस्थ समुदाय के आदि पूर्वज और ईष्ट देव माने जाते हैं।\n\n'
            'वे हाथ में कलम, दवात और पुस्तक धारण करते हैं। न्याय के देवता यमराज की सहायता से वे सभी जीवों के पाप-पुण्य का हिसाब रखते हैं। उनकी आराधना से बुद्धि, विद्या और धर्म की प्राप्ति होती है।',
            style: TextStyle(
              color: const Color(0xFF2D1A00),
              fontSize: 15.sp,
              height: 1.85,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24.h),
          const _InfoCard(
            icon: '🖊️',
            title: 'लेखनी दाता',
            subtitle: 'विद्या, बुद्धि और कलम के देवता — ज्ञान के प्रदाता।',
          ),
          SizedBox(height: 14.h),
          const _InfoCard(
            icon: '⚖️',
            title: 'कर्म के न्यायाधीश',
            subtitle: 'समस्त प्राणियों के कर्मों का सटीक लेखा-जोखा रखते हैं।',
          ),
          SizedBox(height: 14.h),
          const _InfoCard(
            icon: '🌟',
            title: 'ग्रह-नक्षत्र स्वामी',
            subtitle: 'समस्त ग्रहों और नक्षत्रों के अधिपति देवता।',
          ),
          SizedBox(height: 14.h),
          const _InfoCard(
            icon: '🙏',
            title: 'कायस्थ कुलदेव',
            subtitle: 'कायस्थ समुदाय के आदि पूर्वज और परम ईष्ट देव।',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(14.r),
        border: Border(
          left: BorderSide(color: AppColors.saffron, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 22.sp)),
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
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF6E5738),
                    fontSize: 13.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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
  const _StatItem({required this.value, required this.label});

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
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
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
      ['🛕', 'तीन तल्लीय मंदिर', 'भव्य तीन मंजिला मंदिर का निर्माण।'],
      ['💧', 'जल परिक्रमा', 'जल के साथ पवित्र परिक्रमा पथ।'],
      ['🌸', 'नक्षत्र वाटिका', '27 नक्षत्रों के अनुसार वृक्षों की वाटिका।'],
      ['📖', 'गुरुकुल विद्यापीठ', 'वैदिक शिक्षा और सनातन परंपरा।'],
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
          SizedBox(height: 18.h),
          ...features.map(
            (item) => Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(22.r),
                border: Border(
                  top: BorderSide(color: AppColors.saffron, width: 3),
                ),
              ),
              child: Column(
                children: [
                  Text(item[0], style: TextStyle(fontSize: 34.sp)),
                  SizedBox(height: 8.h),
                  Text(
                    item[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7A1E1E),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item[2],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF6E5738),
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF240800).withOpacity(0.92),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
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

          SizedBox(height: 10.h),

          Text(
            'हमारा उद्देश्य',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 25.sp,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 16.h),

          Container(
            width: 80.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          SizedBox(height: 22.h),

          Text(
            'भगवान श्री चित्रगुप्त जी के सत्य, न्याय, धर्म एवं कर्तव्य के '
            'शाश्वत संदेश को प्रत्येक व्यक्ति तक पहुँचाना हमारा परम उद्देश्य है। '
            'श्री चित्रगुप्त पीठ सनातन संस्कृति, वैदिक शिक्षा, योग, ध्यान, '
            'पर्यावरण संरक्षण तथा सेवा कार्यों के माध्यम से एक जागरूक, '
            'संस्कारित एवं समरस समाज के निर्माण हेतु निरंतर समर्पित है।\n\n'
            'हमारा लक्ष्य केवल एक धार्मिक स्थल का निर्माण नहीं, बल्कि आने वाली '
            'पीढ़ियों को भारतीय संस्कृति, नैतिक मूल्यों, कर्तव्यनिष्ठ जीवन और '
            'आध्यात्मिक चेतना से जोड़कर एक सशक्त एवं आदर्श राष्ट्र के निर्माण में '
            'अपना योगदान देना है।',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 15.sp,
              height: 1.9,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 24.h),

          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3A1309),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldLight,
                  size: 28.sp,
                ),

                SizedBox(width: 14.w),

                Expanded(
                  child: Text(
                    '“धर्म, ज्ञान, सेवा और न्याय के पथ पर चलकर मानवता का कल्याण करना ही श्री चित्रगुप्त पीठ का संकल्प है।”',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
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

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Text(
        '🕉️ SHREE CHITRAGUPT PEETH\n\nसम्पूर्ण भारत में भगवान श्री चित्रगुप्त जी के बहुत से मंदिर हैं, परंतु उनके बारे में सभी जानकारी एक स्थान से प्राप्त हो — इसी उद्देश्य से श्री चित्रगुप्त पीठ की स्थापना की गई है।\n\n📞 +91-7065013874\n✉️ shreechitraguptpeeth@gmail.com',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 13.sp,
          height: 1.7,
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
          child: Image.asset(HomeScreen._bgImage, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.70)),
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
          child: Icon(icon, color: AppColors.goldLight, size: 24.sp),
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
                style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
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
              Icon(icon, color: AppColors.goldLight, size: 30.sp),
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
                style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              ),
            ],
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
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: child,
    );
  }
}