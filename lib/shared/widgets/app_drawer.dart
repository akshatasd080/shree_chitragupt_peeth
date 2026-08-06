import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modern dark navy navigation drawer matching the design mockups.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const Color drawerBg = Color(0xFF0D1B2A);
  static const Color iconTileBg = Color(0xFFE8E8E8);

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
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: drawerBg,
      width: 300.w,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
              child: Row(
                children: [
                  _IconSquare(
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
            ),
            Divider(color: Colors.white.withOpacity(0.18), height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelect(index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            _IconSquare(icon: item.icon),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
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
    );
  }
}

class DrawerItemData {
  const DrawerItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
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
        color: AppDrawer.iconTileBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: const Color(0xFF4A4A4A), size: 22.sp),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: child,
    );
  }
}
