// home_config.dart
import 'package:flutter/foundation.dart';

class HeroBannerCta {
  final String label;
  final String route;

  HeroBannerCta({required this.label, required this.route});

  factory HeroBannerCta.fromJson(Map<String, dynamic> json) {
    return HeroBannerCta(
      label: json['label'] as String,
      route: json['route'] as String,
    );
  }
}

class HeroBannerData {
  final String title;
  final String subtitle;
  final String image;
  final HeroBannerCta cta;

  HeroBannerData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.cta,
  });

  factory HeroBannerData.fromJson(Map<String, dynamic> json) {
    return HeroBannerData(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      image: json['image'] as String,
      cta: HeroBannerCta.fromJson(json['cta'] as Map<String, dynamic>),
    );
  }
}

class HighlightsItem {
  final String icon;
  final String label;

  HighlightsItem({required this.icon, required this.label});

  factory HighlightsItem.fromJson(Map<String, dynamic> json) {
    return HighlightsItem(
      icon: json['icon'] as String,
      label: json['label'] as String,
    );
  }
}

class HighlightsData {
  final List<HighlightsItem> items;

  HighlightsData({required this.items});

  factory HighlightsData.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List;
    return HighlightsData(
      items: itemsList.map((item) => HighlightsItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class FeaturedRoom {
  final String id;
  final String name;
  final String image;

  FeaturedRoom({required this.id, required this.name, required this.image});

  factory FeaturedRoom.fromJson(Map<String, dynamic> json) {
    return FeaturedRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}

class FeaturedRoomsData {
  final List<FeaturedRoom> rooms;

  FeaturedRoomsData({required this.rooms});

  factory FeaturedRoomsData.fromJson(Map<String, dynamic> json) {
    final roomsList = json['rooms'] as List;
    return FeaturedRoomsData(
      rooms: roomsList.map((room) => FeaturedRoom.fromJson(room as Map<String, dynamic>)).toList(),
    );
  }
}

class GalleryPreviewData {
  final List<String> images;

  GalleryPreviewData({required this.images});

  factory GalleryPreviewData.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List;
    return GalleryPreviewData(
      images: imagesList.map((image) => image as String).toList(),
    );
  }
}

class Section {
  final String type;
  final dynamic data;

  Section({required this.type, required this.data});

  factory Section.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final dataJson = json['data'] as Map<String, dynamic>;
    
    dynamic data;
    
    switch (type) {
      case 'heroBanner':
        data = HeroBannerData.fromJson(dataJson);
        break;
      case 'highlights':
        data = HighlightsData.fromJson(dataJson);
        break;
      case 'featuredRooms':
        data = FeaturedRoomsData.fromJson(dataJson);
        break;
      case 'galleryPreview':
        data = GalleryPreviewData.fromJson(dataJson);
        break;
      default:
        throw ArgumentError('Unknown section type: $type');
    }
    
    return Section(type: type, data: data);
  }
}

class HomeConfig {
  final List<Section> sections;

  HomeConfig({required this.sections});

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List;
    return HomeConfig(
      sections: sectionsList.map((section) => Section.fromJson(section as Map<String, dynamic>)).toList(),
    );
  }
}