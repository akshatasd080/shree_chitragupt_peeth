import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String _bgImage = 'assets/images/chitragupt_bhagwan.jpg';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Guest User';
  String email = 'user@example.com';
  String mobile = '+91 XXXXX XXXXX';
  String accountType = 'Devotee Account';

  bool isLoggingOut = false;

  Future<void> _logout() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditProfileScreen(
          name: name,
          email: email,
          mobile: mobile,
          accountType: accountType,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result['name'] ?? name;
        email = result['email'] ?? email;
        mobile = result['mobile'] ?? mobile;
        accountType = result['accountType'] ?? accountType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PageBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 110.h, 18.w, 90.h),
        child: Column(
          children: [
            Container(
              height: 108.w,
              width: 108.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.saffron, AppColors.gold],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 60.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'जय श्री चित्रगुप्त जी की जय 🙏',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Welcome to Shree Chitragupt Peeth App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 24.h),
            _ProfileCard(
              icon: Icons.person_outline_rounded,
              title: 'Name',
              value: name,
            ),
            SizedBox(height: 12.h),
            _ProfileCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),
            SizedBox(height: 12.h),
            _ProfileCard(
              icon: Icons.phone_outlined,
              title: 'Mobile',
              value: mobile,
            ),
            SizedBox(height: 12.h),
            _ProfileCard(
              icon: Icons.verified_user_outlined,
              title: 'Account Type',
              value: accountType,
            ),
            SizedBox(height: 24.h),
            _ProfileButton(
              icon: Icons.edit_rounded,
              title: 'Edit Profile',
              color: AppColors.saffron,
              onTap: _editProfile,
            ),
            SizedBox(height: 12.h),
            _ProfileButton(
              icon: Icons.logout_rounded,
              title: isLoggingOut ? 'Logging out...' : 'Logout',
              color: Colors.redAccent,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.mobile,
    required this.accountType,
  });

  final String name;
  final String email;
  final String mobile;
  final String accountType;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController mobileController;
  late final TextEditingController accountTypeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    mobileController = TextEditingController(text: widget.mobile);
    accountTypeController = TextEditingController(text: widget.accountType);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    accountTypeController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    Navigator.pop(
      context,
      {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'accountType': accountTypeController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.goldLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.goldLight,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ProfileScreen._bgImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.72),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.withOpacity(0.08),
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 40.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EditField(
                        controller: nameController,
                        label: 'Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      SizedBox(height: 18.h),
                      _EditField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 18.h),
                      _EditField(
                        controller: mobileController,
                        label: 'Mobile',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 18.h),
                      _EditField(
                        controller: accountTypeController,
                        label: 'Account Type',
                        icon: Icons.verified_user_outlined,
                      ),
                      SizedBox(height: 35.h),
                      SizedBox(
                        width: double.infinity,
                        height: 60.h,
                        child: ElevatedButton.icon(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.saffron,
                            elevation: 10,
                            shadowColor: AppColors.saffron.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                          ),
                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Save Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.goldLight,
          fontSize: 13.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.goldLight,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.105),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 18.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.16),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: AppColors.goldLight,
            width: 1.4,
          ),
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
            ProfileScreen._bgImage,
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
                  AppColors.saffron.withOpacity(0.16),
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.92),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.105),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.goldLight,
            size: 28.sp,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 14.sp,
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

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
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
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}