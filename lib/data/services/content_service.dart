import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/content_models.dart';

/// Fetches public content from the existing backend APIs.
class ContentService {
  ContentService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Newest created/added content first across all sections.
  static List<T> _newestFirst<T>(
    List<T> items,
    DateTime Function(T item) sortDate,
  ) {
    items.sort((a, b) => sortDate(b).compareTo(sortDate(a)));
    return items;
  }

  Future<List<HeroSlide>> fetchHeroSlides() async {
    final data = await _client.get(
      ApiConfig.heroSlides,
      query: {'active': 'true'},
    );
    final list = data['slides'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => HeroSlide.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<YoutubeVideoItem>> fetchYoutubeVideos({
    int? limit,
    bool latest = true,
  }) async {
    final query = <String, String>{
      'active': 'true',
      if (latest) 'latest': 'true',
      if (limit != null) 'limit': '$limit',
    };
    final data = await _client.get(ApiConfig.youtubeVideos, query: query);
    final list = data['videos'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => YoutubeVideoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<DailyThought?> fetchTodayThought() async {
    final data = await _client.get(
      ApiConfig.dailyThoughts,
      query: {'today': 'true'},
    );
    final thought = data['thought'];
    if (thought is Map) {
      return DailyThought.fromJson(Map<String, dynamic>.from(thought));
    }
    return null;
  }

  Future<List<DailyThought>> fetchDailyThoughts() async {
    final data = await _client.get(
      ApiConfig.dailyThoughts,
      query: {'active': 'true'},
    );
    final list = data['thoughts'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => DailyThought.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<NewsLinkItem>> fetchNewsLinks() async {
    final data = await _client.get(
      ApiConfig.newsLinks,
      query: {'active': 'true'},
    );
    final list = data['links'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => NewsLinkItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<NewsImageItem>> fetchNewsImages({bool monthly = true}) async {
    final data = await _client.get(
      ApiConfig.newsImages,
      query: monthly ? {'monthly': 'true'} : {'active': 'true'},
    );
    final list = data['images'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => NewsImageItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<NewsVideoItem>> fetchNewsVideos({bool monthly = true}) async {
    final data = await _client.get(
      ApiConfig.newsVideos,
      query: monthly ? {'monthly': 'true'} : {'active': 'true'},
    );
    final list = data['videos'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => NewsVideoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<EventItem>> fetchEvents({String type = 'upcoming'}) async {
    final data = await _client.get(
      ApiConfig.events,
      query: {'active': 'true', 'type': type},
    );
    final list = data['events'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => EventItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<GalleryImageItem>> fetchGalleryImages() async {
    final data = await _client.get(
      ApiConfig.galleryImages,
      query: {'active': 'true'},
    );
    final list = data['images'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => GalleryImageItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<GalleryVideoItem>> fetchGalleryVideos() async {
    final data = await _client.get(
      ApiConfig.galleryVideos,
      query: {'active': 'true'},
    );
    final list = data['videos'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => GalleryVideoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<PoojaItem>> fetchPoojas() async {
    final data = await _client.get(
      ApiConfig.poojas,
      query: {'active': 'true'},
    );
    final list = data['poojas'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => PoojaItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<List<SpiritualResource>> fetchSpiritualResources({
    String? type,
  }) async {
    final query = <String, String>{
      'active': 'true',
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final data =
        await _client.get(ApiConfig.spiritualResources, query: query);
    final list = data['resources'] as List? ?? [];
    return _newestFirst(
      list
          .whereType<Map>()
          .map((e) => SpiritualResource.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (e) => e.sortDate,
    );
  }

  Future<String> submitContact({
    required String name,
    required String email,
    required String mobile,
    String? message,
  }) async {
    final data = await _client.post(
      ApiConfig.contacts,
      body: {
        'name': name,
        'email': email,
        'mobile_number': mobile,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    return data['message']?.toString() ?? 'Request submitted successfully';
  }

  Future<String> submitMember({
    required String fullName,
    required String email,
    required String mobile,
    String? city,
    String? state,
    String? profession,
    String? message,
  }) async {
    final data = await _client.postMultipart(
      ApiConfig.members,
      fields: {
        'full_name': fullName,
        'email': email,
        'mobile_number': mobile,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
        if (profession != null && profession.isNotEmpty)
          'profession': profession,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    return data['message']?.toString() ??
        'Membership request submitted successfully';
  }

  Future<String> submitPoojaBooking({
    required String name,
    required String email,
    required String mobile,
    required String pooja,
    required String bookingDate,
    String? bookingTime,
    String? message,
  }) async {
    final data = await _client.post(
      ApiConfig.poojaBookings,
      body: {
        'name': name,
        'email': email,
        'mobile': mobile,
        'pooja': pooja,
        'booking_date': bookingDate,
        if (bookingTime != null && bookingTime.isNotEmpty)
          'booking_time': bookingTime,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    return data['message']?.toString() ??
        'Pooja request submitted successfully';
  }

  Future<String> submitDonation({
    required String name,
    required String mobile,
    required num amount,
    String? email,
    String? message,
  }) async {
    final data = await _client.post(
      ApiConfig.donations,
      body: {
        'name': name,
        'mobile': mobile,
        'amount': amount,
        if (email != null && email.isNotEmpty) 'email': email,
        if (message != null && message.isNotEmpty) 'message': message,
        'amount_type': 'custom',
        'preferred_method': 'all',
      },
    );
    return data['message']?.toString() ?? 'Donation recorded successfully';
  }
}
