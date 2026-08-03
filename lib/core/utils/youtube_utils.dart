/// Helpers for YouTube URLs returned by the backend.
class YoutubeUtils {
  YoutubeUtils._();

  static String? extractVideoId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final raw = url.trim();

    final uri = Uri.tryParse(raw);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();

    if (host.contains('youtu.be')) {
      if (uri.pathSegments.isEmpty) return null;
      return uri.pathSegments.first;
    }

    if (host.contains('youtube.com') || host.contains('youtube-nocookie.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;

      final segments = uri.pathSegments;
      if (segments.length >= 2) {
        if (segments[0] == 'embed' ||
            segments[0] == 'shorts' ||
            segments[0] == 'live' ||
            segments[0] == 'v') {
          return segments[1];
        }
      }
    }

    // Bare 11-char video id
    final idOnly = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idOnly.hasMatch(raw)) return raw;

    return null;
  }

  static String thumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
