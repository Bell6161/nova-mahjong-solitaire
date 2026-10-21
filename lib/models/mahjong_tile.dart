class MahjongTile {
  final String id;
  final String category; // 'wan', 'dot', 'bamboo', 'dragon', 'wind', 'season', 'flower'
  final String value;    // '1'..'9', 'red', 'green', 'white', 'east'..'north', etc.
  final double x;        // Grid X coordinate (supports half-steps for overlapping layouts)
  final double y;        // Grid Y coordinate
  final int z;           // Layer / Height (0 = base, 1, 2, 3...)
  bool isRemoved;
  bool isSelected;
  bool isHinted;

  MahjongTile({
    required this.id,
    required this.category,
    required this.value,
    required this.x,
    required this.y,
    required this.z,
    this.isRemoved = false,
    this.isSelected = false,
    this.isHinted = false,
  });

  /// Check if this tile matches another tile under Mahjong Solitaire rules
  bool matches(MahjongTile other) {
    if (id == other.id) return false;
    // Seasons match any other season (optional, but in casual exact match or family match)
    if (category == 'season' && other.category == 'season') return true;
    // Flowers match any other flower
    if (category == 'flower' && other.category == 'flower') return true;
    // Regular suits must match exactly
    return category == other.category && value == other.value;
  }

  /// Unique match group identifier
  String get matchGroup {
    if (category == 'season') return 'season_any';
    if (category == 'flower') return 'flower_any';
    return '${category}_$value';
  }

  /// Asset file name
  String get assetName => '${category}_$value.png';

  MahjongTile copyWith({
    String? id,
    String? category,
    String? value,
    double? x,
    double? y,
    int? z,
    bool? isRemoved,
    bool? isSelected,
    bool? isHinted,
  }) {
    return MahjongTile(
      id: id ?? this.id,
      category: category ?? this.category,
      value: value ?? this.value,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      isRemoved: isRemoved ?? this.isRemoved,
      isSelected: isSelected ?? this.isSelected,
      isHinted: isHinted ?? this.isHinted,
    );
  }
}
