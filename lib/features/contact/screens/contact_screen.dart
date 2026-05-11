 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String phoneNumber1 = '+917065013874';
  static const String phoneNumber2 = '+917065013871';
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
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

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

  Future<void> _openDialer(BuildContext context, String number) async {
    await _launch(context, Uri(scheme: 'tel', path: number));
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
    return Container(
      color: const Color(0xFFFDF6E3),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 110.h, 20.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '📍',
                style: TextStyle(fontSize: 46.sp),
              ),
            ),
            SizedBox(height: 8.h),

            Center(
              child: Text(
                'संपर्क करें',
                style: TextStyle(
                  color: const Color(0xFF6B1A1A),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            Center(
              child: Text(
                'CONTACT & LOCATION — SHREE CHITRAGUPT PEETH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 34.h),

            Text(
              'CONTACT US',
              style: TextStyle(
                color: AppColors.saffron.withOpacity(0.75),
                fontSize: 13.sp,
                letterSpacing: 5,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'पता एवं सम्पर्क विवरण',
              style: TextStyle(
                color: const Color(0xFF7A1E1E),
                fontSize: 25.sp,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(height: 10.h),

            Container(
              height: 4.h,
              width: 85.w,
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            SizedBox(height: 28.h),

            _InfoRow(
              iconText: '📍',
              title: 'ADDRESS / पता',
              value: address,
              buttonText: 'Google Maps पर देखें',
              onTap: () => _openMap(context),
            ),

            SizedBox(height: 24.h),

            _InfoRow(
              iconText: '📞',
              title: 'PHONE / फोन',
              value: '$displayPhone1\n$displayPhone2',
              buttonText: 'Call Now',
              onTap: () => _openDialer(context, phoneNumber1),
            ),

            SizedBox(height: 24.h),

            _InfoRow(
              iconText: '✉️',
              title: 'EMAIL / ईमेल',
              value: email,
              buttonText: 'Send Email',
              onTap: () => _openEmail(context),
            ),

            SizedBox(height: 24.h),

            _InfoRow(
              iconText: '🌐',
              title: 'WEBSITE / वेबसाइट',
              value: displayWebsite,
              buttonText: 'Open Website',
              onTap: () => _openWebsite(context),
            ),

            SizedBox(height: 24.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(iconText: '🔗'),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SmallTitle('SOCIAL MEDIA'),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: [
                          _SocialButton(
                            text: '▶ YouTube',
                            color: Colors.red,
                            onTap: () => _openYoutube(context),
                          ),
                          _SocialButton(
                            text: '📷 Instagram',
                            color: const Color(0xFFC13584),
                            onTap: () => _openInstagram(context),
                          ),
                          _SocialButton(
                            text: '💬 WhatsApp',
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            GestureDetector(
              onTap: () => _openMap(context),
              child: Container(
                height: 260.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEAF2F6),
                      Color(0xFFD7E3EA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SimpleMapPainter(),
                      ),
                    ),
                    Positioned(
                      top: 16.h,
                      left: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Open in Maps ↗',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '📍',
                        style: TextStyle(fontSize: 54.sp),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A1E1E),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          'Brij Shanti Kunj, Vrindavan-Govardhan Marg, UP 281504',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18.h),

            Row(
              children: [
                Expanded(
                  child: _LargeActionButton(
                    text: '🗺️ Google Maps पर देखें',
                    filled: true,
                    onTap: () => _openMap(context),
                  ),
                ),
                SizedBox(width: 12.w),
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(iconText: iconText),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmallTitle(title),
                SizedBox(height: 8.h),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF2D1A00),
                    fontSize: 15.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppColors.saffron,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
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

class _IconBox extends StatelessWidget {
  const _IconBox({required this.iconText});

  final String iconText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.w,
      width: 58.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.saffron,
            AppColors.gold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          iconText,
          style: TextStyle(fontSize: 25.sp),
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
        fontSize: 13.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
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
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w900,
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
      height: 54.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? AppColors.saffron : const Color(0xFFFDF6E3),
          side: BorderSide(
            color: filled ? Colors.transparent : AppColors.gold,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? Colors.white : AppColors.gold,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
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