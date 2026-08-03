import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central API configuration for the Flutter app.
/// Matches the web frontend: `VITE_BASE_URL=http://localhost:3004/api`
///
/// Change [customBaseUrl] when testing on a physical device
/// (use your PC LAN IP, e.g. `http://192.168.1.10:3004/api`).
class ApiConfig {
  ApiConfig._();

  /// Optional override for physical devices / production.
  /// Leave empty to use the platform-aware default below.
  static const String customBaseUrl = '';

  static String get baseUrl {
    if (customBaseUrl.isNotEmpty) return customBaseUrl;

    if (kIsWeb) return 'http://localhost:3004/api';

    // Android emulator reaches host machine via 10.0.2.2
    if (Platform.isAndroid) return 'http://10.0.2.2:3004/api';

    // iOS simulator / desktop
    return 'http://localhost:3004/api';
  }

  // ── Endpoints (relative to [baseUrl]) ──────────────────────────
  static const String heroSlides = '/hero-slides';
  static const String youtubeVideos = '/youtube-videos';
  static const String dailyThoughts = '/daily-thoughts';
  static const String newsImages = '/news-images';
  static const String newsVideos = '/news-videos';
  static const String newsLinks = '/news-links';
  static const String events = '/events';
  static const String galleryImages = '/gallery-images';
  static const String galleryVideos = '/gallery-videos';
  static const String poojas = '/poojas';
  static const String poojaBookings = '/pooja-bookings';
  static const String contacts = '/contacts';
  static const String members = '/members';
  static const String donations = '/donations';
  static const String spiritualResources = '/spiritual-resources';

  // ── Upload folders ─────────────────────────────────────────────
  static String uploadUrl(String folder, String? filename) {
    if (filename == null || filename.isEmpty) return '';
    return '$baseUrl/uploads/$folder/$filename';
  }

  static String heroImage(String? filename) => uploadUrl('hero', filename);
  static String poojaImage(String? filename) => uploadUrl('pooja', filename);
  static String thoughtImage(String? filename) =>
      uploadUrl('thoughts', filename);
  static String newsImage(String? filename) => uploadUrl('news', filename);
  static String newsVideo(String? filename) =>
      uploadUrl('news-videos', filename);
  static String eventImage(String? filename) => uploadUrl('events', filename);
  static String galleryImage(String? filename) =>
      uploadUrl('gallery', filename);
  static String spiritualImage(String? filename) =>
      uploadUrl('spiritual', filename);
}
