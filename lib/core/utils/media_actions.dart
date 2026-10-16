import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class MediaActions {
  MediaActions._();

  /// Uses Gal's write-only gallery access — no READ_MEDIA_* permissions.
  static Future<bool> _ensureGalleryAccess(BuildContext context) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (hasAccess) return true;

      final granted = await Gal.requestAccess(toAlbum: true);
      if (granted) return true;
    } on GalException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery access error: ${e.type.name}')),
        );
      }
      return false;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallery permission required to save media.'),
        ),
      );
    }
    return false;
  }

  static Future<void> downloadImage(
    BuildContext context,
    String imageUrl, {
    String? name,
  }) async {
    if (imageUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image URL')),
        );
      }
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    final ok = await _ensureGalleryAccess(context);
    if (!ok) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Downloading image...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final ext = _extractExtension(imageUrl, defaultExt: 'jpg');
      final fileName =
          name ?? 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = '${tempDir.path}/$fileName';

      final dio = Dio();
      await dio.download(
        imageUrl,
        filePath,
        options: Options(headers: {'Cache-Control': 'no-cache'}),
      );

      await Gal.putImage(filePath, album: 'Shree Chitragupt Peeth');

      try {
        await File(filePath).delete();
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> downloadVideo(
    BuildContext context,
    String videoUrl, {
    String? name,
  }) async {
    if (videoUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid video URL')),
        );
      }
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    final ok = await _ensureGalleryAccess(context);
    if (!ok) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Downloading video...'),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final ext = _extractExtension(videoUrl, defaultExt: 'mp4');
      final fileName =
          name ?? 'vid_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = '${tempDir.path}/$fileName';

      final dio = Dio();
      int? lastPct;
      await dio.download(
        videoUrl,
        filePath,
        options: Options(headers: {'Cache-Control': 'no-cache'}),
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final pct = ((received / total) * 100).floor();
          if (lastPct == null || pct - lastPct! >= 10) {
            lastPct = pct;
            messenger.showSnackBar(
              SnackBar(
                content: Text('Downloading video... $pct%'),
                duration: const Duration(milliseconds: 800),
              ),
            );
          }
        },
      );

      await Gal.putVideo(filePath, album: 'Shree Chitragupt Peeth');

      try {
        await File(filePath).delete();
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved to gallery ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _extractExtension(String url, {required String defaultExt}) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final i = path.lastIndexOf('.');
      if (i < 0 || i == path.length - 1) return defaultExt;
      final ext = path.substring(i + 1).toLowerCase();
      if (RegExp(r'^[a-z0-9]{1,6}$').hasMatch(ext)) return ext;
      return defaultExt;
    } catch (_) {
      return defaultExt;
    }
  }
}
