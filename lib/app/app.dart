import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import 'theme/app_theme.dart';

class ShreeChitraguptPeethApp extends StatelessWidget {
  const ShreeChitraguptPeethApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          home: FutureBuilder<bool>(
            future: _checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _SplashLoader();
              }

              final bool isLoggedIn = snapshot.data ?? false;

              if (isLoggedIn) {
                return const HomeScreen(
                  key: ValueKey('home_screen_after_restart'),
                );
              }

              return const LoginScreen(
                key: ValueKey('login_screen_after_logout'),
              );
            },
          ),
        );
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF090400),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}