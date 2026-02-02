// home_page.dart
import 'package:flutter/material.dart';
import 'package:vc_flutter_app/services/config_service.dart';
import 'package:vc_flutter_app/ui/models/home/home_config.dart';
import 'package:vc_flutter_app/ui/widgets/home/hero_banner_section.dart';
import 'package:vc_flutter_app/ui/widgets/home/highlights_section.dart';
import 'package:vc_flutter_app/ui/widgets/home/featured_rooms_section.dart';
import 'package:vc_flutter_app/ui/widgets/home/gallery_preview_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomeConfig> _configFuture;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    _configFuture = ConfigService().getHomeConfig().then((data) {
      return HomeConfig.fromJson(data);
    });
  }

  void _retryLoadConfig() {
    setState(() {
      _loadConfig();
    });
  }

  Widget _buildSection(Section section) {
    try {
      switch (section.type) {
        case 'heroBanner':
          return HeroBannerSection(data: section.data as HeroBannerData);
        case 'highlights':
          return HighlightsSection(data: section.data as HighlightsData);
        case 'featuredRooms':
          return FeaturedRoomsSection(data: section.data as FeaturedRoomsData);
        case 'galleryPreview':
          return GalleryPreviewSection(data: section.data as GalleryPreviewData);
        default:
          return Container(); // Unknown section type
      }
    } catch (e) {
      // Fallback for parsing errors
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Error loading section: ${section.type}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Virtual Campus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<HomeConfig>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading campus...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load content',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _retryLoadConfig,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            final config = snapshot.data!;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Render sections with spacing
                  ...config.sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == config.sections.length - 1 ? 0 : 32,
                      ),
                      child: _buildSection(section),
                    );
                  }),
                ],
              ),
            );
          }

          return Container(); // Fallback
        },
      ),
    );
  }
}