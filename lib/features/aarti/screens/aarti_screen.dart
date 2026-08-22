import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/temple_bell_service.dart';
import '../../../shared/widgets/page_background.dart';

class AartiScreen extends StatefulWidget {
  const AartiScreen({super.key, this.isActive = false});

  /// Whether this tab is currently visible in the home shell.
  final bool isActive;

  @override
  State<AartiScreen> createState() => _AartiScreenState();
}

class _AartiSectionData {
  const _AartiSectionData({
    required this.title,
    required this.subtitle,
    required this.stanzas,
    required this.refrain,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<String> stanzas;
  final String refrain;
  final IconData icon;
}

class _AartiScreenState extends State<AartiScreen> with WidgetsBindingObserver {
  final _bell = TempleBellService.instance;
  bool _isBellPlaying = false;
  bool _bellBusy = false;
  StreamSubscription<bool>? _bellPlayingSub;

  static const _aartiRefrain = 'ॐ जय चित्रगुप्त हरे...॥';
  static const _stutiRefrain = 'शरणागतम ,शरणागतम||';

  static const _sections = [
    _AartiSectionData(
      title: 'श्री चित्रगुप्त भगवान आरती',
      subtitle: 'भक्ति भाव से पठन करें',
      refrain: _aartiRefrain,
      icon: Icons.local_fire_department_rounded,
      stanzas: [
        'ॐ जय चित्रगुप्त हरे, स्वामी जय चित्रगुप्त हरे।\n'
            'भक्त जनों के इच्छित, फल को पूर्ण करे॥',
        'विघ्न विनाशक मंगलकर्ता, सन्तन सुखदायी।\n'
            'भक्तन के प्रतिपालक, त्रिभुवन यश छायी॥',
        'रूप चतुर्भुज, श्यामल मूरति, पीताम्बर राजै।\n'
            'मातु इरावती, दक्षिणा, वाम अङ्ग साजै॥',
        'कष्ट निवारण, दुष्ट संहारण, प्रभु अन्तर्यामी।\n'
            'सृष्टि संहारण, जन दु:ख हारण, प्रकट हुये स्वामी॥',
        'कलम, दवात, तलवार, पत्रिका, कर में अति सोहै।\n'
            'वैजयन्ती वनमाला, त्रिभुवन मन मोहै॥',
        'सिंहासन का कार्य सम्भाला, ब्रह्मा हर्षाये।\n'
            'तैंतीस कोटि देवता, चरणन में धाये॥',
        'नृपति सौदास, भीष्म पितामह, याद तुम्हें कीन्हा।\n'
            'वेगि विलम्ब न लायो, इच्छित फल दीन्हा॥',
        'दारा, सुत, भगिनी, सब अपने स्वास्थ के कर्ता।\n'
            'जाऊँ कहाँ शरण में किसकी, तुम तज मैं भर्ता॥',
        'बन्धु, पिता तुम स्वामी, शरण गहूँ किसकी।\n'
            'तुम बिन और न दूजा, आस करूँ जिसकी॥',
        'जो जन चित्रगुप्त जी की आरती, प्रेम सहित गावैं।\n'
            'चौरासी के छूटैं बंधन, इच्छित फल पावैं॥',
        'न्यायाधीश बैकुण्ठ निवासी, पाप पुण्य लिखते।\n'
            'हम हैं शरण तिहारी, आस न दूजी करते॥',
      ],
    ),
    _AartiSectionData(
      title: 'श्री चित्रगुप्त भगवान स्तुति',
      subtitle: 'प्रभु की शरण में',
      refrain: _stutiRefrain,
      icon: Icons.volunteer_activism_rounded,
      stanzas: [
        'जय चित्रगुप्त यमेश तव, शरणागतम, शरणागतम|\n'
            'जय पूज्य पद पद्मेश तव शरणागतम, शरणागतम||',
        'जय देव देव दयानिधे, जय दीनबंधु कृपानिधे |\n'
            'कर्मेश तव धर्मेश तव शरणागतम, शरणागतम||',
        'जय चित्र अवतारी प्रभो, जय लेखनीधारी विभो |\n'
            'जय श्याम तन चित्रेश तव शरणागतम, शरणागतम||',
        'पुरुषादि भगवत् अंश जय, कायस्थ कुल अवतंश जय |\n'
            'जय शक्ति बुद्धि विशेष तव शरणागतम, शरणागतम||',
        'जय विज्ञ मंत्री धर्म के, ज्ञाता शुभाशुभ कर्म के |\n'
            'जय शांतिमय न्यायेश तव शरणागतम, शरणागतम||',
        'तव नाथ नाम प्रताप से, छूट जाएँ भय त्रय ताप से |\n'
            'हों दूर सर्व क्लेश तव शरणागतम, शरणागतम||',
        'हों दीन अनुरागी हरि, चाहें दया दृष्टि तेरी |\n'
            'कीजै कृपा करुणेश तव शरणागतम, शरणागतम||',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bellPlayingSub = _bell.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isBellPlaying = playing);
    });
    _verifyBellAsset();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startBell());
    }
  }

  Future<void> _verifyBellAsset() async {
    try {
      await rootBundle.load(TempleBellService.assetPath);
    } catch (e) {
      debugPrint('Temple bell asset missing: $e');
    }
  }

  Future<void> _startBell() async {
    if (_bellBusy) return;
    setState(() => _bellBusy = true);
    try {
      await _bell.play();
      HapticFeedback.lightImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'घंटी नहीं बज सकी। App band karke dubara run karein.',
            ),
            backgroundColor: AppColors.maroon,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _bellBusy = false);
    }
  }

  Future<void> _stopBell() async {
    await _bell.pause();
  }

  Future<void> _toggleBell() async {
    HapticFeedback.selectionClick();
    if (_isBellPlaying) {
      await _stopBell();
    } else {
      await _startBell();
    }
  }

  @override
  void didUpdateWidget(AartiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startBell();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopBell();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive && _isBellPlaying) {
      _startBell();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopBell();
    }
  }

  Future<void> _reload() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bellPlayingSub?.cancel();
    _stopBell();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
          children: [
            const SectionTitle(
              title: 'भगवान चित्रगुप्त जी की आरती',
              subtitle: 'Daily prayer & stuti',
              icon: Icons.menu_book_rounded,
            ),
            SizedBox(height: 8.h),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _bellBusy ? null : _toggleBell,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: _isBellPlaying
                        ? AppColors.saffron.withOpacity(0.28)
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: _isBellPlaying
                          ? AppColors.goldLight
                          : Colors.white.withOpacity(0.35),
                      width: _isBellPlaying ? 1.6 : 1,
                    ),
                    boxShadow: _isBellPlaying
                        ? [
                            BoxShadow(
                              color: AppColors.goldLight.withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_bellBusy)
                        SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.goldLight,
                          ),
                        )
                      else
                        Icon(
                          _isBellPlaying
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: AppColors.goldLight,
                          size: 20.sp,
                        ),
                      SizedBox(width: 10.w),
                      Text(
                        _bellBusy
                            ? 'घंटी शुरू हो रही है...'
                            : _isBellPlaying
                                ? 'मंदिर घंटी बंद करें'
                                : 'मंदिर घंटी बजाएँ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ..._sections.map(
              (section) => Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: _SpiritualAartiCard(section: section),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpiritualAartiCard extends StatelessWidget {
  const _SpiritualAartiCard({required this.section});

  final _AartiSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFF0DC),
            Color(0xFFFFE8CC),
          ],
        ),
        border: Border.all(color: AppColors.saffron.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.saffron.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.saffron,
                      AppColors.gold,
                      AppColors.deepSaffron,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -12.w,
              top: -10.h,
              child: Icon(
                section.icon,
                size: 90.sp,
                color: AppColors.saffron.withOpacity(0.07),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          section.icon,
                          color: AppColors.saffron,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: TextStyle(
                                color: const Color(0xFF7A1E1E),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              section.subtitle,
                              style: TextStyle(
                                color: AppColors.saffron,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '॥ ॐ ॥',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.saffron,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ...section.stanzas.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stanza = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _StanzaBlock(
                        number: index + 1,
                        text: stanza,
                        refrain: section.refrain,
                        isLast: index == section.stanzas.length - 1,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StanzaBlock extends StatelessWidget {
  const _StanzaBlock({
    required this.number,
    required this.text,
    required this.refrain,
    required this.isLast,
  });

  final int number;
  final String text;
  final String refrain;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.saffron.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: AppColors.saffron,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF2D1A00),
                  fontSize: 15.sp,
                  height: 1.75,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  refrain,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.deepSaffron,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) ...[
          SizedBox(height: 4.h),
          Center(
            child: Container(
              width: 40.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.35),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
