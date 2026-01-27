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
      _configFuture = ConfigService().getHomeConfig().then((data) {
        return HomeConfig.fromJson(data);
      });
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
          return Container();
      }
    } catch (e) {
      // Log error and return empty container
      debugPrint('Error building section ${section.type}: $e');
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Virtual Campus',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: const Icon(Icons.search),
            color: const Color(0xFF1E293B),
          ),
        ],
      ),
      body: FutureBuilder<HomeConfig>(
        future: _configFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading campus...',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load campus data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1E293B),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _retryLoadConfig,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final config = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // Render sections with proper spacing
                ...config.sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  
                  return Column(
                    children: [
                      _buildSection(section),
                      if (index < config.sections.length - 1)
                        const SizedBox(height: 32),
                    ],
                  );
                }),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}