import 'package:flutter/material.dart';

enum ThemeType { traditional, jade, candy, midnight }

class GameTheme {
  final ThemeType type;
  final String name;
  final String subtitle;
  final String tileFolder;
  final Color backgroundColor;
  final Color boardBackgroundColor;
  final Color cardBackgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tileHighlightColor;
  final Color gridLineColor;

  const GameTheme({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.tileFolder,
    required this.backgroundColor,
    required this.boardBackgroundColor,
    required this.cardBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tileHighlightColor,
    required this.gridLineColor,
  });

  /// Path to tile sprite for this theme
  String getTileAsset(String category, String value) {
    return 'assets/images/tiles/$tileFolder/${category}_$value.png';
  }

  // 1. Zen Traditional
  static const GameTheme traditional = GameTheme(
    type: ThemeType.traditional,
    name: 'Zen Traditional',
    subtitle: 'Porcelain & Bamboo',
    tileFolder: 'traditional',
    backgroundColor: Color(0xFF0F241A),
    boardBackgroundColor: Color(0xFF163829),
    cardBackgroundColor: Color(0xFF1C4734),
    primaryTextColor: Color(0xFFE8F5E9),
    secondaryTextColor: Color(0xFFFFD54F),
    tileHighlightColor: Color(0xFFFFD54F),
    gridLineColor: Color(0xFF2D6A4F),
  );

  // 2. Royal Jade & Gold
  static const GameTheme jade = GameTheme(
    type: ThemeType.jade,
    name: 'Royal Jade & Gold',
    subtitle: 'Imperial Emerald Gems',
    tileFolder: 'jade',
    backgroundColor: Color(0xFF1A0A0E),
    boardBackgroundColor: Color(0xFF2D1219),
    cardBackgroundColor: Color(0xFF3E1822),
    primaryTextColor: Color(0xFFFFF8E7),
    secondaryTextColor: Color(0xFFFFD700),
    tileHighlightColor: Color(0xFFFFD700),
    gridLineColor: Color(0xFF6B2233),
  );

  // 3. Candy Sugar Pop
  static const GameTheme candy = GameTheme(
    type: ThemeType.candy,
    name: 'Candy Pop',
    subtitle: 'Sweet Jelly Confections',
    tileFolder: 'candy',
    backgroundColor: Color(0xFFFDF6F0),
    boardBackgroundColor: Color(0xFFF6E8DC),
    cardBackgroundColor: Color(0xFFFFFFFF),
    primaryTextColor: Color(0xFF2C243B),
    secondaryTextColor: Color(0xFFFF2A6D),
    tileHighlightColor: Color(0xFFFF2A6D),
    gridLineColor: Color(0xFFE0CFBE),
  );

  // 4. Midnight Obsidian OLED
  static const GameTheme midnight = GameTheme(
    type: ThemeType.midnight,
    name: 'Midnight OLED',
    subtitle: 'Cyber Obsidian Runes',
    tileFolder: 'midnight',
    backgroundColor: Color(0xFF000000),
    boardBackgroundColor: Color(0xFF0A0C10),
    cardBackgroundColor: Color(0xFF12151D),
    primaryTextColor: Color(0xFFFAFAFA),
    secondaryTextColor: Color(0xFF00E5FF),
    tileHighlightColor: Color(0xFF00E5FF),
    gridLineColor: Color(0xFF1E2330),
  );

  static const List<GameTheme> themes = [traditional, jade, candy, midnight];
}
