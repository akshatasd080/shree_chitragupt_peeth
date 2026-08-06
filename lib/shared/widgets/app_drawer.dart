import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';

/// Navigation drawer matching the app's warm dark theme (saffron + gold).
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onLogout;

  static const Color drawerBg = AppColors.dark;
  static const Color iconTileBg = Color(0xFFFFF3E0);

  static const List<DrawerItemData> items = [
    DrawerItemData(label: 'Home', icon: Icons.home_rounded),
    DrawerItemData(label: 'YouTube Videos', icon: Icons.play_circle_outline),
    DrawerItemData(label: 'News Images', icon: Icons.photo_outlined),
    DrawerItemData(label: 'News Videos', icon: Icons.videocam_outlined),
    DrawerItemData(label: 'News Links', icon: Icons.link_rounded),
    DrawerItemData(label: 'Events', icon: Icons.event_rounded),
    DrawerItemData(
        label: 'Daily Thought', icon: Icons.lightbulb_outline_rounded),
    DrawerItemData(label: 'Contact', icon: Icons.phone_in_talk_rounded),
    DrawerItemData(label: 'Member', icon: Icons.person_add_alt_1_rounded),
    DrawerItemData(label: 'Pooja Booking', icon: Icons.temple_hindu_rounded),
    DrawerItemData(label: 'Donation', icon: Icons.volunteer_activism_rounded),
    DrawerItemData(label: 'Gallery Images', icon: Icons.photo_library_outlined),
    DrawerItemData(
        label: 'Gallery Videos', icon: Icons.ondemand_video_outlined),
    DrawerItemData(label: 'Aarti', icon: Icons.menu_book_rounded),
    DrawerItemData(label: 'Profile', icon: Icons.person_rounded),
    DrawerItemData(label: 'Logout', icon: Icons.logout_rounded, isLogout: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/images/chitragupt_bhagwan.jpg',
            fit: BoxFit.cover,
          )),
          Positioned.fill(
              child: Container(
            color: AppColors.black.withOpacity(0.78),
          )),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.saffron.withOpacity(0.18),
                AppColors.dark.withOpacity(0.5),
                AppColors.dark.withOpacity(0.96),
              ],
            ),
          ))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _HeaderIconButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpeg',
                              width: 72.w,
                              height: 72.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 72.w,
                                height: 72.w,
                                color: Colors.white12,
                                child: Icon(
                                  Icons.temple_hindu_rounded,
                                  color: Colors.white70,
                                  size: 36.sp,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(width: 44.w),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'श्री चित्रगुप्त पीठ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'वृंदावन धाम',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    color: AppColors.goldLight.withOpacity(0.3),
                    height: 1,
                    thickness: 1),
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLogout = item.isLogout;
                      final selected = !isLogout && selectedIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            Navigator.of(context).pop();
                            if (isLogout) {
                              onLogout?.call();
                            } else {
                              onSelect(index);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isLogout
                                  ? Colors.redAccent.withOpacity(0.08)
                                  : (selected
                                      ? AppColors.goldLight.withOpacity(0.10)
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(12.r),
                              border: isLogout
                                  ? Border.all(
                                      color: Colors.redAccent.withOpacity(0.3))
                                  : (selected
                                      ? Border.all(
                                          color: AppColors.goldLight
                                              .withOpacity(0.25))
                                      : null),
                            ),
                            child: Row(
                              children: [
                                isLogout
                                    ? Container(
                                        width: 42.w,
                                        height: 42.w,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          border: Border.all(
                                              color: Colors.redAccent
                                                  .withOpacity(0.35)),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: Colors.redAccent,
                                          size: 22.sp,
                                        ),
                                      )
                                    : _IconSquare(icon: item.icon),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: isLogout
                                          ? Colors.redAccent
                                          : (selected
                                              ? AppColors.goldLight
                                              : Colors.white),
                                      fontSize: 15.sp,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.goldLight,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class DrawerItemData {
  const DrawerItemData({
    required this.label,
    required this.icon,
    this.isLogout = false,
  });

  final String label;
  final IconData icon;
  final bool isLogout;
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            color: AppColors.goldLight,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.saffron, AppColors.gold],
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22.sp),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: child,
    );
  }
}
