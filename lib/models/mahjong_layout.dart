class TileSlot {
  final double x;
  final double y;
  final int z;

  const TileSlot(this.x, this.y, this.z);
}

class MahjongLayout {
  final int id;
  final String name;
  final String difficulty;
  final int tileCount;
  final List<TileSlot> slots;

  const MahjongLayout({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.tileCount,
    required this.slots,
  });

  /// 1. Zen Lotus (32 tiles / 16 pairs)
  static MahjongLayout lotus() {
    final List<TileSlot> s = [];
    // Base ring (Z=0, 24 tiles)
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    // Top Lotus Core (Z=1, 8 tiles)
    for (int r = 1; r < 3; r++) {
      for (int c = 1; c < 5; c++) {
        s.add(TileSlot(c + 0.5, r.toDouble(), 1));
      }
    }
    return MahjongLayout(
      id: 1,
      name: 'Zen Lotus',
      difficulty: 'Relaxed',
      tileCount: s.length,
      slots: s,
    );
  }

  /// 2. Mini Turtle (48 tiles / 24 pairs)
  static MahjongLayout miniTurtle() {
    final List<TileSlot> s = [];
    // Layer 0: Shell base (36 tiles)
    for (int r = 0; r < 6; r++) {
      for (int c = 1; c < 7; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    // Head & Tail & Flippers (4 tiles)
    s.add(const TileSlot(0, 2.5, 0)); // Left Flipper
    s.add(const TileSlot(7, 2.5, 0)); // Right Flipper
    // Layer 1: Raised shell (8 tiles)
    for (int r = 2; r < 4; r++) {
      for (int c = 2; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
      }
    }
    // Layer 2: Pinnacle (2 tiles)
    s.add(const TileSlot(3.5, 2.5, 2));
    s.add(const TileSlot(4.5, 2.5, 2));

    // Pad or trim to even number (48 tiles)
    final trimmed = s.take(48).toList();
    return MahjongLayout(
      id: 2,
      name: 'Mini Turtle',
      difficulty: 'Easy',
      tileCount: trimmed.length,
      slots: trimmed,
    );
  }

  /// 3. Pyramid Peak (64 tiles / 32 pairs)
  static MahjongLayout pyramid() {
    final List<TileSlot> s = [];
    // Base 6x6 (36 tiles)
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    // Tier 1: 4x4 (16 tiles)
    for (int r = 1; r < 5; r++) {
      for (int c = 1; c < 5; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
      }
    }
    // Tier 2: 3x3 (8 tiles)
    for (int r = 2; r < 4; r++) {
      for (int c = 1.5.toInt(); c < 5; c++) {
        if (s.length < 60) s.add(TileSlot(c + 0.5, r + 0.5, 2));
      }
    }
    // Tier 3: Apex (4 tiles)
    s.add(const TileSlot(2.5, 2.5, 3));
    s.add(const TileSlot(3.0, 2.5, 3));
    s.add(const TileSlot(2.5, 3.0, 3));
    s.add(const TileSlot(3.0, 3.0, 3));

    final count = (s.length ~/ 2) * 2;
    final validSlots = s.take(count).toList();
    return MahjongLayout(
      id: 3,
      name: 'Pyramid Peak',
      difficulty: 'Medium',
      tileCount: validSlots.length,
      slots: validSlots,
    );
  }

  /// 4. Imperial Fortress (80 tiles / 40 pairs)
  static MahjongLayout fortress() {
    final List<TileSlot> s = [];
    // Perimeter wall (Layer 0, 48 tiles)
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 8; c++) {
        if (r == 0 || r == 6 || c == 0 || c == 7 || (r >= 2 && r <= 4 && c >= 2 && c <= 5)) {
          s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
        }
      }
    }
    // 4 Corner Towers (Layer 1, 16 tiles)
    final corners = [(0.0, 0.0), (6.0, 0.0), (0.0, 5.0), (6.0, 5.0)];
    for (var (cx, cy) in corners) {
      s.add(TileSlot(cx + 0.5, cy + 0.5, 1));
      s.add(TileSlot(cx + 1.0, cy + 0.5, 1));
    }
    // Central Keep (Layer 1 & 2, 16 tiles)
    for (int r = 2; r <= 4; r++) {
      for (int c = 3; c <= 4; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
        s.add(TileSlot(c + 0.5, r.toDouble(), 2));
      }
    }

    final count = (s.length ~/ 2) * 2;
    final validSlots = s.take(count).toList();
    return MahjongLayout(
      id: 4,
      name: 'Imperial Fortress',
      difficulty: 'Hard',
      tileCount: validSlots.length,
      slots: validSlots,
    );
  }

  /// 5. Grand Turtle (100 tiles / 50 pairs)
  static MahjongLayout grandTurtle() {
    final List<TileSlot> s = [];
    // Full layered Turtle layout
    for (int r = 0; r < 8; r++) {
      for (int c = 1; c < 9; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    s.add(const TileSlot(0.0, 3.5, 0)); // Outer Left Nose
    s.add(const TileSlot(9.0, 3.5, 0)); // Outer Right Tail
    
    // Tier 1
    for (int r = 2; r < 6; r++) {
      for (int c = 3; c < 7; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
      }
    }
    // Tier 2
    for (int r = 3; r < 5; r++) {
      for (int c = 4; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 2));
      }
    }
    // Top Pinnacle
    s.add(const TileSlot(4.5, 3.5, 3));
    s.add(const TileSlot(5.5, 3.5, 3));

    final count = (s.length ~/ 2) * 2;
    final validSlots = s.take(count).toList();
    return MahjongLayout(
      id: 5,
      name: 'The Grand Turtle',
      difficulty: 'Master',
      tileCount: validSlots.length,
      slots: validSlots,
    );
  }

  static List<MahjongLayout> allStages() => [
    lotus(),
    miniTurtle(),
    pyramid(),
    fortress(),
    grandTurtle(),
  ];
}
