import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  static const String phoneNumber1 = '+917065013874';
  static const String displayPhone1 = '+91-7065013874';
  static const String displayPhone2 = '+91-7065013871';
  static const String whatsappNumber = '917065013874';
  static const String email = 'shreechitraguptpeeth@gmail.com';
  static const String website = 'https://www.shreechitraguptpeeth.org/';
  static const String displayWebsite = 'www.shreechitraguptpeeth.org';

  static const String address =
      'Shree Chitragupt Peeth (Brij Shanti Kunj)\n'
      'GGWF+2R6, Junhaidi,\n'
      'Vrindavan-Govardhan Marg,\n'
      'Uttar Pradesh - 281504';

  static const String mapQuery =
      'Shree Chitragupt Peeth Brij Shanti Kunj GGWF+2R6 Junhaidi Vrindavan Govardhan Marg Uttar Pradesh 281504';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open. Please try again.')),
      );
    }
  }

  Future<void> _openMap(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapQuery)}',
    );
    await _launch(context, uri);
  }

  Future<void> _openDialer(BuildContext context) async {
    await _launch(context, Uri(scheme: 'tel', path: phoneNumber1));
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      'जय श्री चित्रगुप्त जी की जय 🙏\nमुझे श्री चित्रगुप्त पीठ के बारे में जानकारी चाहिए।',
    );

    await _launch(
      context,
      Uri.parse('https://wa.me/$whatsappNumber?text=$message'),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Shree Chitragupt Peeth Contact',
        'body':
            'जय श्री चित्रगुप्त जी की जय,\n\nमुझे श्री चित्रगुप्त पीठ के बारे में जानकारी चाहिए।\n\nधन्यवाद',
      },
    );

    await _launch(context, uri);
  }

  Future<void> _openWebsite(BuildContext context) async {
    await _launch(context, Uri.parse(website));
  }

  Future<void> _openYoutube(BuildContext context) async {
    await _launch(
      context,
      Uri.parse('https://www.youtube.com/@shreechitraguptpeeth3940'),
    );
  }

  Future<void> _openInstagram(BuildContext context) async {
    await _launch(
      context,
      Uri.parse('https://www.instagram.com/shreechitraguptpeeth'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(_bgImage, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.64)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.18),
                  const Color(0xFF2B0D00).withOpacity(0.62),
                  Colors.black.withOpacity(0.88),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 115.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeading(
                  label: 'CONTACT US',
                  title: 'पता एवं सम्पर्क विवरण',
                ),

                SizedBox(height: 16.h),

                _InfoCard(
                  iconText: '📍',
                  title: 'ADDRESS / पता',
                  value: address,
                  buttonText: 'Google Maps पर देखें',
                  onTap: () => _openMap(context),
                ),

                SizedBox(height: 14.h),

                _InfoCard(
                  iconText: '📞',
                  title: 'PHONE / फोन',
                  value: '$displayPhone1\n$displayPhone2',
                  buttonText: 'Call Now',
                  onTap: () => _openDialer(context),
                ),

                SizedBox(height: 14.h),

                _InfoCard(
                  iconText: '✉️',
                  title: 'EMAIL / ईमेल',
                  value: email,
                  buttonText: 'Send Email',
                  onTap: () => _openEmail(context),
                ),

                SizedBox(height: 14.h),

                _InfoCard(
                  iconText: '🌐',
                  title: 'WEBSITE / वेबसाइट',
                  value: displayWebsite,
                  buttonText: 'Open Website',
                  onTap: () => _openWebsite(context),
                ),

                SizedBox(height: 14.h),

                _SocialMediaCard(
                  onYoutubeTap: () => _openYoutube(context),
                  onInstagramTap: () => _openInstagram(context),
                  onWhatsAppTap: () => _openWhatsApp(context),
                ),

                SizedBox(height: 18.h),

                GestureDetector(
                  onTap: () => _openMap(context),
                  child: Container(
                    height: 210.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEAF2F6),
                          Color(0xFFD7E3EA),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.r),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SimpleMapPainter(),
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            left: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Open in Maps ↗',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '📍',
                              style: TextStyle(fontSize: 46.sp),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(13.w),
                              color: const Color(0xFF7A1E1E),
                              child: Text(
                                'Brij Shanti Kunj, Vrindavan-Govardhan Marg, UP 281504',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                Row(
                  children: [
                    Expanded(
                      child: _LargeActionButton(
                        text: '🗺️ Google Maps',
                        filled: true,
                        onTap: () => _openMap(context),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _LargeActionButton(
                        text: '📌 Full Map',
                        filled: false,
                        onTap: () => _openMap(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.label,
    required this.title,
  });

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.94),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.saffron.withOpacity(0.78),
              fontSize: 12.sp,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF7A1E1E),
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 4.h,
            width: 78.w,
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.iconText,
    required this.title,
    required this.value,
    required this.buttonText,
    required this.onTap,
  });

  final String iconText;
  final String title;
  final String value;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DD).withOpacity(0.94),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(iconText: iconText),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SmallTitle(title),
                    SizedBox(height: 6.h),
                    Text(
                      value,
                      style: TextStyle(
                        color: const Color(0xFF2D1A00),
                        fontSize: 13.5.sp,
                        height: 1.42,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: AppColors.saffron,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialMediaCard extends StatelessWidget {
  const _SocialMediaCard({
    required this.onYoutubeTap,
    required this.onInstagramTap,
    required this.onWhatsAppTap,
  });

  final VoidCallback onYoutubeTap;
  final VoidCallback onInstagramTap;
  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD).withOpacity(0.94),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconBox(iconText: '🔗'),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SmallTitle('SOCIAL MEDIA'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _SocialButton(
                      text: '▶ YouTube',
                      color: Colors.red,
                      onTap: onYoutubeTap,
                    ),
                    _SocialButton(
                      text: '📷 Instagram',
                      color: const Color(0xFFC13584),
                      onTap: onInstagramTap,
                    ),
                    _SocialButton(
                      text: '💬 WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: onWhatsAppTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.iconText});

  final String iconText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.w,
      width: 48.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.saffron,
            AppColors.gold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          iconText,
          style: TextStyle(fontSize: 22.sp),
        ),
      ),
    );
  }
}

class _SmallTitle extends StatelessWidget {
  const _SmallTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF7A5C3A),
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
        minimumSize: Size(0, 36.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.r),
        ),
      ),
      onPressed: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LargeActionButton extends StatelessWidget {
  const _LargeActionButton({
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
          backgroundColor: filled ? AppColors.saffron : Colors.white,
          side: BorderSide(
            color: filled ? Colors.transparent : AppColors.gold,
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? Colors.white : AppColors.gold,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.22)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.16)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.20, 0),
      Offset(size.width * 0.42, size.height),
      thinRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.78, 0),
      Offset(size.width * 0.60, size.height),
      thinRoadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width * 0.65, size.height * 0.10),
      thinRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.15, size.height),
      Offset(size.width, size.height * 0.75),
      thinRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}