class HeroSlide {
  const HeroSlide({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageFilename,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? subtitle;
  final String? imageFilename;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory HeroSlide.fromJson(Map<String, dynamic> json) {
    return HeroSlide(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      displayOrder: _asInt(json['display_order']),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class YoutubeVideoItem {
  const YoutubeVideoItem({
    required this.id,
    required this.title,
    this.description,
    required this.youtubeUrl,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String youtubeUrl;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory YoutubeVideoItem.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      displayOrder: _asInt(json['display_order']),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class DailyThought {
  const DailyThought({
    required this.id,
    this.thoughtHi,
    this.thoughtEn,
    this.imageFilename,
    this.thoughtDate,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? thoughtHi;
  final String? thoughtEn;
  final String? imageFilename;
  final String? thoughtDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  String get primaryText {
    final hi = thoughtHi?.trim() ?? '';
    if (hi.isNotEmpty) return hi;
    return thoughtEn?.trim() ?? '';
  }

  factory DailyThought.fromJson(Map<String, dynamic> json) {
    return DailyThought(
      id: _asInt(json['id']),
      thoughtHi: json['thought_hi']?.toString(),
      thoughtEn: json['thought_en']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      thoughtDate: json['thought_date']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class NewsLinkItem {
  const NewsLinkItem({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.linkType,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String url;
  final String? description;
  final String? linkType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory NewsLinkItem.fromJson(Map<String, dynamic> json) {
    return NewsLinkItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString(),
      linkType: json['link_type']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class NewsImageItem {
  const NewsImageItem({
    required this.id,
    this.description,
    this.imageFilename,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? description;
  final String? imageFilename;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory NewsImageItem.fromJson(Map<String, dynamic> json) {
    return NewsImageItem(
      id: _asInt(json['id']),
      description: json['description']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class NewsVideoItem {
  const NewsVideoItem({
    required this.id,
    this.description,
    this.videoFilename,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? description;
  final String? videoFilename;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory NewsVideoItem.fromJson(Map<String, dynamic> json) {
    return NewsVideoItem(
      id: _asInt(json['id']),
      description: json['description']?.toString(),
      videoFilename: json['video_filename']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    this.description,
    this.imageFilename,
    this.eventTime,
    this.location,
    this.eventDate,
    this.eventType,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String? imageFilename;
  final String? eventTime;
  final String? location;
  final String? eventDate;
  final String? eventType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      eventTime: json['event_time']?.toString(),
      location: json['location']?.toString(),
      eventDate: json['event_date']?.toString(),
      eventType: json['event_type']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class GalleryImageItem {
  const GalleryImageItem({
    required this.id,
    required this.title,
    this.imageFilename,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? imageFilename;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory GalleryImageItem.fromJson(Map<String, dynamic> json) {
    return GalleryImageItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      imageFilename: json['image_filename']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class GalleryVideoItem {
  const GalleryVideoItem({
    required this.id,
    required this.title,
    this.description,
    required this.youtubeUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String youtubeUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory GalleryVideoItem.fromJson(Map<String, dynamic> json) {
    return GalleryVideoItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class PoojaItem {
  const PoojaItem({
    required this.id,
    required this.title,
    this.description,
    this.day,
    this.duration,
    this.imageFilename,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String? day;
  final String? duration;
  final String? imageFilename;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory PoojaItem.fromJson(Map<String, dynamic> json) {
    return PoojaItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      day: json['day']?.toString(),
      duration: json['duration']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class SpiritualResource {
  const SpiritualResource({
    required this.id,
    required this.type,
    this.category,
    required this.name,
    this.slug,
    this.content,
    this.imageFilename,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String type;
  final String? category;
  final String name;
  final String? slug;
  final String? content;
  final String? imageFilename;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime get sortDate => _contentSortDate(createdAt, updatedAt);

  factory SpiritualResource.fromJson(Map<String, dynamic> json) {
    return SpiritualResource(
      id: _asInt(json['id']),
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      content: json['content']?.toString(),
      imageFilename: json['image_filename']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

/// Newest created first; fall back to updated_at when created_at is missing.
DateTime _contentSortDate(DateTime? createdAt, DateTime? updatedAt) {
  return createdAt ??
      updatedAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
