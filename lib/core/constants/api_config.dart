import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central API configuration
class ApiConfig {
  ApiConfig._();
  
  /// PC ka LAN IP (Real Android Device ke liye)
  static const String customBaseUrl = 'http://192.168.1.39:3004/api';

  static String get baseUrl {
    // Agar customBaseUrl diya hua hai to wahi use hoga
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }

    // Flutter Web
    if (kIsWeb) {
      return 'http://localhost:3004/api';
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3004/api';
    }

    // iOS Simulator / Desktop
    return 'http://localhost:3004/api';
  }

  // ---------------- API Endpoints ----------------

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

  // ---------------- Upload URLs ----------------

  static String uploadUrl(String folder, String? filename) {
    if (filename == null || filename.isEmpty) return '';
    return '$baseUrl/uploads/$folder/$filename';
  }

  static String heroImage(String? filename) =>
      uploadUrl('hero', filename);

  static String poojaImage(String? filename) =>
      uploadUrl('pooja', filename);

  static String thoughtImage(String? filename) =>
      uploadUrl('thoughts', filename);

  static String newsImage(String? filename) =>
      uploadUrl('news', filename);

  static String newsVideo(String? filename) =>
      uploadUrl('news-videos', filename);

  static String eventImage(String? filename) =>
      uploadUrl('events', filename);

  static String galleryImage(String? filename) =>
      uploadUrl('gallery', filename);

  static String spiritualImage(String? filename) =>
      uploadUrl('spiritual', filename);
}