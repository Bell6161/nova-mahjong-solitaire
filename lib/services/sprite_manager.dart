import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/game_theme.dart';

class SpriteManager {
  static final Map<String, ui.Image> _imageCache = {};
  static bool _isLoading = false;

  static const List<String> tileTypes = [
    'wan_1', 'wan_2', 'wan_3', 'wan_4', 'wan_5', 'wan_6', 'wan_7', 'wan_8', 'wan_9',
    'dot_1', 'dot_2', 'dot_3', 'dot_4', 'dot_5', 'dot_6', 'dot_7', 'dot_8', 'dot_9',
    'bamboo_1', 'bamboo_2', 'bamboo_3', 'bamboo_4', 'bamboo_5', 'bamboo_6', 'bamboo_7', 'bamboo_8', 'bamboo_9',
    'dragon_red', 'dragon_green', 'dragon_white',
    'wind_east', 'wind_south', 'wind_west', 'wind_north',
    'season_spring', 'season_summer', 'season_autumn', 'season_winter',
    'flower_plum', 'flower_orchid', 'flower_bamboo', 'flower_chrysanthemum',
  ];

  static bool isThemeLoaded(String themeFolder) {
    return _imageCache.containsKey('${themeFolder}_wan_1');
  }

  static ui.Image? getTileImage(String themeFolder, String category, String value) {
    final key = '${themeFolder}_${category}_$value';
    return _imageCache[key];
  }

  /// Preload all 42 tiles for the requested theme into GPU memory
  static Future<void> preloadTheme(String themeFolder) async {
    if (isThemeLoaded(themeFolder) || _isLoading) return;
    _isLoading = true;

    try {
      final futures = <Future<void>>[];
      for (final type in tileTypes) {
        final key = '${themeFolder}_$type';
        if (!_imageCache.containsKey(key)) {
          final assetPath = 'assets/images/tiles/$themeFolder/$type.png';
          futures.add(_loadImage(key, assetPath));
        }
      }
      await Future.wait(futures);
    } finally {
      _isLoading = false;
    }
  }

  static Future<void> _loadImage(String key, String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _imageCache[key] = fi.image;
    } catch (e) {
      // Graceful fallback for debug / test environments
    }
  }

  /// Preload all 4 themes in the background
  static Future<void> preloadAllThemes() async {
    for (final theme in GameTheme.themes) {
      await preloadTheme(theme.tileFolder);
    }
  }
}
