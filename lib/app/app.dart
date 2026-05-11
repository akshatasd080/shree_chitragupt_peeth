import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import 'theme/app_theme.dart';
import '../features/auth/screens/login_screen.dart';

class ShreeChitraguptPeethApp extends StatelessWidget {
  const ShreeChitraguptPeethApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}

class SplashHomeScreen extends StatelessWidget {
  const SplashHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.saffron.withOpacity(0.25),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.r),
                    child: Image.asset(
                      'assets/images/chitragupt_bhagwan.jpg',
                      width: 220.w,
                      height: 260.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 26.h),

                Text(
                  'श्री चित्रगुप्त पीठ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Vrindavan, Uttar Pradesh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),

                SizedBox(height: 22.h),

                Text(
                  '🙏 जय श्री चित्रगुप्त महाराज 🙏',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepSaffron,
                  ),
                ),

                SizedBox(height: 34.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Enter App',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}