import 'package:flutter/material.dart';
import 'package:vc_flutter_app/services/config_service.dart';
import 'package:vc_flutter_app/navigation/app_navigation.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late Future<Map<String, dynamic>> _navConfigFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _navConfigFuture = ConfigService().getNavConfig();
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'home': Icons.home,
      'bed': Icons.bed,
      'info': Icons.info,
      'call': Icons.call,
      'local_offer': Icons.local_offer,
      'planning': Icons.event_note,
      'bookmark': Icons.bookmark,
      'person': Icons.person,
      'settings': Icons.settings,
      'menu': Icons.menu,
    };
    return iconMap[iconName] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _navConfigFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingNavBar();
        }

        if (snapshot.hasError) {
          return _buildErrorNavBar(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildErrorNavBar('No navigation configuration found');
        }

        final config = snapshot.data!;
        final items = (config['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final visibleItems = items.where((item) => item['visible'] == true).toList();

        if (visibleItems.isEmpty) {
          return _buildErrorNavBar('No visible navigation items');
        }

        return _buildGlassmorphicNavBar(visibleItems);
      },
    );
  }

  Widget _buildLoadingNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorNavBar(String error) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Text(
          'Navigation Error',
          style: TextStyle(
            color: Colors.red.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicNavBar(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = _currentIndex == index;
                
                return _buildNavItem(
                  icon: _getIconData(item['icon']),
                  label: item['label'] ?? '',
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    AppNavigation.instance.goToIndex(index);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366f1),
                    const Color(0xFF8b5cf6),
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.15 : 1.0),
              child: Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.7,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}