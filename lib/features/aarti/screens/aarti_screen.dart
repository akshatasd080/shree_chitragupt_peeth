import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class AartiScreen extends StatelessWidget {
  const AartiScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

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

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(AartiScreen._bgImage, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.70)),
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
        Icon(icon, color: AppColors.goldLight, size: 28.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  )),
              Text(subtitle,
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.105),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.88),
          fontSize: 15.sp,
          height: 1.8,
        ),
      ),
    );
  }
}