import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/content_models.dart';
import '../../../data/services/content_service.dart';
import '../../../shared/widgets/page_background.dart';

class AartiScreen extends StatefulWidget {
  const AartiScreen({super.key});

  @override
  State<AartiScreen> createState() => _AartiScreenState();
}

class _AartiScreenState extends State<AartiScreen> {
  final _service = ContentService();
  late Future<List<SpiritualResource>> _future;

  static const String _fallbackAarti =
      'ॐ जय चित्रगुप्त हरे,\n'
      'स्वामी जय चित्रगुप्त हरे।\n'
      'भक्त जनों के संकट,\n'
      'क्षण में दूर करे॥\n\n'
      'जय देव जय देव,\n'
      'श्री चित्रगुप्त देवा।\n'
      'सुख संपत्ति दाता,\n'
      'सबके भाग्य विधाता॥\n\n'
      'हे प्रभु चित्रगुप्त भगवान,\n'
      'हम सब पर अपनी कृपा बनाए रखें।';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchSpiritualResources(type: 'aarti');
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchSpiritualResources(type: 'aarti');
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: RefreshIndicator(
        color: AppColors.goldLight,
        onRefresh: _reload,
        child: FutureBuilder<List<SpiritualResource>>(
          future: _future,
          builder: (context, snapshot) {
            final resources = snapshot.data ?? [];
            final showFallback = snapshot.connectionState ==
                    ConnectionState.done &&
                (snapshot.hasError || resources.isEmpty);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 40.h),
              children: [
                const SectionTitle(
                  title: 'भगवान चित्रगुप्त जी की आरती',
                  subtitle: 'Daily prayer',
                  icon: Icons.menu_book_rounded,
                ),
                SizedBox(height: 16.h),
                if (snapshot.connectionState != ConnectionState.done)
                  const LoadingCard()
                else if (showFallback)
                  _AartiCard(text: _fallbackAarti)
                else
                  ...resources.map(
                    (r) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _AartiCard(
                        title: r.name,
                        text: (r.content ?? '').trim().isEmpty
                            ? _fallbackAarti
                            : r.content!,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AartiCard extends StatelessWidget {
  const _AartiCard({required this.text, this.title});

  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((title ?? '').isNotEmpty) ...[
            Text(
              title!,
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
