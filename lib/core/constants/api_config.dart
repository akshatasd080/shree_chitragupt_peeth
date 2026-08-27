enum Environment {
  local,
  prod,
}

class ApiConfig {
  /// Change only this value.
  ///
  /// local = Local development server
  /// prod  = Production server
  static const Environment current = Environment.prod;

  static String get baseUrl {
    switch (current) {
      case Environment.local:
        return 'http://192.168.1.29:3004/api';

      case Environment.prod:
        return 'https://shreechitraguptpeeth.org/api';
    }
  }

  // ============================================================
  // API ENDPOINTS
  // ============================================================

  // ---------------- Content ----------------

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

  // ---------------- Auth ----------------

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';

  // ============================================================
  // UPLOAD URLs
  // ============================================================

  static String uploadUrl(
    String folder,
    String? filename,
  ) {
    if (filename == null || filename.isEmpty) {
      return '';
    }

    return '$baseUrl/uploads/$folder/$filename';
  }

  static String heroImage(String? filename) {
    return uploadUrl('hero', filename);
  }

  static String poojaImage(String? filename) {
    return uploadUrl('pooja', filename);
  }

  static String thoughtImage(String? filename) {
    return uploadUrl('thoughts', filename);
  }

  static String newsImage(String? filename) {
    return uploadUrl('news', filename);
  }

  static String newsVideo(String? filename) {
    return uploadUrl('news-videos', filename);
  }

  static String eventImage(String? filename) {
    return uploadUrl('events', filename);
  }

  static String galleryImage(String? filename) {
    return uploadUrl('gallery', filename);
  }

  static String spiritualImage(String? filename) {
    return uploadUrl('spiritual', filename);
  }
}