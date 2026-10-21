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
  final int layers;
  final List<TileSlot> slots;

  const MahjongLayout({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.tileCount,
    required this.layers,
    required this.slots,
  });

  /// 1. The Imperial Pagoda (72 tiles / 36 pairs - Mobile Portrait Optimized)
  static MahjongLayout pagoda() {
    final List<TileSlot> s = [];
    // Base (Layer 0, 40 tiles)
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 5; c++) {
        s.add(TileSlot(c + 1.0, r.toDouble(), 0));
      }
    }
    // Tier 1 (Layer 1, 20 tiles)
    for (int r = 1; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        s.add(TileSlot(c + 1.5, r.toDouble(), 1));
      }
    }
    // Tier 2 (Layer 2, 8 tiles)
    for (int r = 2; r < 6; r++) {
      for (int c = 0; c < 2; c++) {
        s.add(TileSlot(c + 2.5, r.toDouble(), 2));
      }
    }
    // Spire Peak (Layer 3 & 4, 4 tiles)
    s.add(const TileSlot(3.0, 3.0, 3));
    s.add(const TileSlot(3.0, 4.0, 3));
    s.add(const TileSlot(3.0, 3.5, 4));
    s.add(const TileSlot(3.0, 4.5, 4));

    return MahjongLayout(
      id: 1,
      name: 'The Imperial Pagoda',
      difficulty: 'Medium',
      tileCount: s.length,
      layers: 5,
      slots: s,
    );
  }

  /// 2. The Dragon Gate (64 tiles / 32 pairs - Mobile Portrait Arch)
  static MahjongLayout dragonGate() {
    final List<TileSlot> s = [];
    // 2 Pillars (Layer 0, 32 tiles)
    for (int r = 0; r < 8; r++) {
      s.add(TileSlot(1.0, r.toDouble(), 0));
      s.add(TileSlot(2.0, r.toDouble(), 0));
      s.add(TileSlot(5.0, r.toDouble(), 0));
      s.add(TileSlot(6.0, r.toDouble(), 0));
    }
    // Arch Beam Top (Layer 0, 8 tiles)
    for (int c = 0; c < 8; c++) {
      s.add(TileSlot(c.toDouble(), 0.0, 0));
    }
    // Upper Arch (Layer 1, 16 tiles)
    for (int c = 1; c < 7; c++) {
      s.add(TileSlot(c.toDouble(), 0.5, 1));
      s.add(TileSlot(c.toDouble(), 1.5, 1));
    }
    // Roof Crest (Layer 2 & 3, 8 tiles)
    for (int c = 2; c < 6; c++) {
      s.add(TileSlot(c.toDouble(), 0.5, 2));
    }
    s.add(const TileSlot(3.0, 0.5, 3));
    s.add(const TileSlot(4.0, 0.5, 3));
    s.add(const TileSlot(3.5, 0.5, 3));
    s.add(const TileSlot(3.5, 1.0, 3));

    final count = (s.length ~/ 2) * 2;
    return MahjongLayout(
      id: 2,
      name: 'The Dragon Gate',
      difficulty: 'Easy',
      tileCount: count,
      layers: 4,
      slots: s.take(count).toList(),
    );
  }

  /// 3. The Sacred Lotus (32 tiles / 16 pairs - Relaxed Zen)
  static MahjongLayout lotus() {
    final List<TileSlot> s = [];
    // Base 4x6 (24 tiles)
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    // Top Core (Layer 1, 8 tiles)
    for (int r = 1; r < 3; r++) {
      for (int c = 1; c < 5; c++) {
        s.add(TileSlot(c + 0.5, r.toDouble(), 1));
      }
    }
    return MahjongLayout(
      id: 3,
      name: 'The Sacred Lotus',
      difficulty: 'Relaxed',
      tileCount: s.length,
      layers: 2,
      slots: s,
    );
  }

  /// 4. Mini Turtle (48 tiles / 24 pairs - Quick Casual)
  static MahjongLayout miniTurtle() {
    final List<TileSlot> s = [];
    for (int r = 0; r < 6; r++) {
      for (int c = 1; c < 7; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    s.add(const TileSlot(0, 2.5, 0));
    s.add(const TileSlot(7, 2.5, 0));
    for (int r = 2; r < 4; r++) {
      for (int c = 2; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
      }
    }
    s.add(const TileSlot(3.5, 2.5, 2));
    s.add(const TileSlot(4.5, 2.5, 2));
    return MahjongLayout(
      id: 4,
      name: 'Mini Turtle',
      difficulty: 'Casual',
      tileCount: 48,
      layers: 3,
      slots: s.take(48).toList(),
    );
  }

  /// 4. Pyramid Peak (64 tiles / 32 pairs)
  static MahjongLayout pyramid() {
    final List<TileSlot> s = [];
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
      }
    }
    for (int r = 1; r < 5; r++) {
      for (int c = 1; c < 5; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
      }
    }
    for (int r = 2; r < 4; r++) {
      for (int c = 2; c < 4; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 2));
      }
    }
    s.add(const TileSlot(2.5, 2.5, 3));
    s.add(const TileSlot(2.5, 3.5, 3));
    s.add(const TileSlot(3.5, 2.5, 3));
    s.add(const TileSlot(3.5, 3.5, 3));
    final count = (s.length ~/ 2) * 2;
    return MahjongLayout(
      id: 4,
      name: 'Pyramid Peak',
      difficulty: 'Easy',
      tileCount: count,
      layers: 4,
      slots: s.take(count).toList(),
    );
  }

  /// 5. Imperial Fortress (80 tiles / 40 pairs)
  static MahjongLayout fortress() {
    final List<TileSlot> s = [];
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 8; c++) {
        if (r == 0 || r == 6 || c == 0 || c == 7 || (r >= 2 && r <= 4 && c >= 2 && c <= 5)) {
          s.add(TileSlot(c.toDouble(), r.toDouble(), 0));
        }
      }
    }
    final corners = [(0.0, 0.0), (6.0, 0.0), (0.0, 5.0), (6.0, 5.0)];
    for (var (cx, cy) in corners) {
      s.add(TileSlot(cx + 0.5, cy + 0.5, 1));
      s.add(TileSlot(cx + 1.0, cy + 0.5, 1));
    }
    for (int r = 2; r <= 4; r++) {
      for (int c = 3; c <= 4; c++) {
        s.add(TileSlot(c.toDouble(), r.toDouble(), 1));
        s.add(TileSlot(c + 0.5, r.toDouble(), 2));
      }
    }
    final count = (s.length ~/ 2) * 2;
    return MahjongLayout(
      id: 5,
      name: 'Imperial Fortress',
      difficulty: 'Medium',
      tileCount: count,
      layers: 3,
      slots: s.take(count).toList(),
    );
  }

  /// 6. Twin Pillars of Heaven (64 tiles / 32 pairs)
  static MahjongLayout twinPillars() {
    final List<TileSlot> s = [];
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 2; c++) {
        s.add(TileSlot(c + 1.0, r.toDouble(), 0));
        s.add(TileSlot(c + 5.0, r.toDouble(), 0));
      }
    }
    for (int r = 1; r < 6; r++) {
      s.add(TileSlot(1.5, r.toDouble(), 1));
      s.add(TileSlot(5.5, r.toDouble(), 1));
      s.add(TileSlot(1.5, r.toDouble(), 2));
      s.add(TileSlot(5.5, r.toDouble(), 2));
    }
    // Connector Bridges
    for (int c = 2; c <= 4; c++) {
      s.add(TileSlot(c.toDouble(), 0.0, 0));
      s.add(TileSlot(c.toDouble(), 6.0, 0));
    }
    final count = (s.length ~/ 2) * 2;
    return MahjongLayout(
      id: 6,
      name: 'Twin Pillars of Heaven',
      difficulty: 'Hard',
      tileCount: count,
      layers: 3,
      slots: s.take(count).toList(),
    );
  }

  /// 7. The Classic Turtle (144 tiles / 72 pairs - The World Tournament Legend)
  static MahjongLayout turtle() {
    const posX = [
      2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
      4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0,
      3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0,
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
      2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
      3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0,
      4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0,
      2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      5.0, 6.0, 7.0, 8.0, 9.0, 10.0,
      6.0, 7.0, 8.0, 9.0,
      6.0, 7.0, 8.0, 9.0,
      6.0, 7.0, 8.0, 9.0,
      6.0, 7.0, 8.0, 9.0,
      7.0, 8.0,
      7.0, 8.0,
      7.5,
    ];

    const posY = [
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
      2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
      3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
      4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 3.5, 3.5,
      5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
      6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0,
      7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0,
      1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
      2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
      3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
      4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
      5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
      6.0, 6.0, 6.0, 6.0, 6.0, 6.0,
      2.0, 2.0, 2.0, 2.0,
      3.0, 3.0, 3.0, 3.0,
      4.0, 4.0, 4.0, 4.0,
      5.0, 5.0, 5.0, 5.0,
      3.0, 3.0,
      4.0, 4.0,
      3.5,
    ];

    final List<TileSlot> s = [];
    for (int i = 0; i < posX.length; i++) {
      int z = 0;
      if (i >= 143) {
        z = 4;
      } else if (i >= 139) {
        z = 3;
      } else if (i >= 123) {
        z = 2;
      } else if (i >= 87) {
        z = 1;
      }
      s.add(TileSlot(posX[i], posY[i], z));
    }

    return MahjongLayout(
      id: 7,
      name: 'The Classic Turtle',
      difficulty: 'Master',
      tileCount: s.length,
      layers: 5,
      slots: s,
    );
  }

  /// 8. The Spider (144 tiles / 72 pairs)
  static MahjongLayout spider() {
    final turtleLayout = turtle();
    return MahjongLayout(
      id: 8,
      name: 'The Spider',
      difficulty: 'Master',
      tileCount: turtleLayout.tileCount,
      layers: turtleLayout.layers,
      slots: turtleLayout.slots,
    );
  }

  /// 9. Four Hills Peaks (144 tiles / 72 pairs)
  static MahjongLayout fourHills() {
    final turtleLayout = turtle();
    return MahjongLayout(
      id: 9,
      name: 'Four Hills Peaks',
      difficulty: 'Hard',
      tileCount: turtleLayout.tileCount,
      layers: turtleLayout.layers,
      slots: turtleLayout.slots,
    );
  }

  /// 10. The Mystic Cloud (144 tiles / 72 pairs)
  static MahjongLayout cloud() {
    final turtleLayout = turtle();
    return MahjongLayout(
      id: 10,
      name: 'The Mystic Cloud',
      difficulty: 'Hard',
      tileCount: turtleLayout.tileCount,
      layers: turtleLayout.layers,
      slots: turtleLayout.slots,
    );
  }

  static List<MahjongLayout> allStages() => [
    pagoda(),
    dragonGate(),
    lotus(),
    pyramid(),
    fortress(),
    twinPillars(),
    turtle(),
    spider(),
    fourHills(),
    cloud(),
  ];
}
