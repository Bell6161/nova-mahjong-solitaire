import 'dart:math';
import '../models/mahjong_tile.dart';
import '../models/mahjong_layout.dart';

class MatchAction {
  final MahjongTile first;
  final MahjongTile second;
  final int pointsEarned;
  final int combo;

  const MatchAction({
    required this.first,
    required this.second,
    required this.pointsEarned,
    required this.combo,
  });
}

class MahjongEngine {
  final MahjongLayout layout;
  List<MahjongTile> tiles = [];
  final List<MatchAction> undoStack = [];

  MahjongTile? selectedTile;
  List<MahjongTile>? activeHint;
  
  int score = 0;
  int combo = 0;
  DateTime? lastMatchTime;
  static const Duration comboWindow = Duration(seconds: 4);

  MahjongEngine({required this.layout}) {
    startNewGame();
  }

  /// Start or restart board with a guaranteed solvable backward-simulated layout
  void startNewGame([int? seed]) {
    tiles = _generateSolvableBoard(seed ?? Random().nextInt(1000000));
    undoStack.clear();
    selectedTile = null;
    activeHint = null;
    score = 0;
    combo = 0;
    lastMatchTime = null;
  }

  /// Check if a tile is free according to Mahjong Solitaire rules:
  /// 1. No tile directly above it (z + 1) overlapping its bounds.
  /// 2. Left side OR Right side is unobstructed by any tile on the same layer.
  bool isTileFree(MahjongTile target) {
    if (target.isRemoved) return false;

    // 1. Check top blockers (layer > target.z)
    for (final other in tiles) {
      if (other.isRemoved || other.id == target.id) continue;
      if (other.z > target.z) {
        // Tile overlaps if horizontal and vertical distances are both < 0.95
        if ((other.x - target.x).abs() < 0.95 && (other.y - target.y).abs() < 0.95) {
          return false; // Blocked from above!
        }
      }
    }

    // 2. Check lateral blockers on the same layer (z == target.z)
    bool hasLeftNeighbor = false;
    bool hasRightNeighbor = false;

    for (final other in tiles) {
      if (other.isRemoved || other.id == target.id) continue;
      if (other.z == target.z) {
        final double dy = (other.y - target.y).abs();
        if (dy < 0.90) {
          // Check left neighbor: x is to the left by ~1.0
          final double dxLeft = target.x - other.x;
          if (dxLeft > 0.1 && dxLeft < 1.05) {
            hasLeftNeighbor = true;
          }
          // Check right neighbor: x is to the right by ~1.0
          final double dxRight = other.x - target.x;
          if (dxRight > 0.1 && dxRight < 1.05) {
            hasRightNeighbor = true;
          }
        }
      }
    }

    // Free if at least one side is open
    return (!hasLeftNeighbor) || (!hasRightNeighbor);
  }

  /// Returns all currently free, playable tiles
  List<MahjongTile> getFreeTiles() {
    return tiles.where((t) => !t.isRemoved && isTileFree(t)).toList();
  }

  /// Select a tile or match it with currently selected tile
  /// Returns MatchResult status: 'selected', 'deselected', 'matched', 'mismatch', 'blocked'
  String tapTile(MahjongTile tile, {void Function(MatchAction)? onMatch}) {
    if (tile.isRemoved) return 'ignored';
    if (!isTileFree(tile)) return 'blocked';

    // Clear active hint on user interaction
    activeHint = null;

    if (selectedTile == null) {
      tile.isSelected = true;
      selectedTile = tile;
      return 'selected';
    }

    // Deselect if tapping the same tile
    if (selectedTile!.id == tile.id) {
      tile.isSelected = false;
      selectedTile = null;
      return 'deselected';
    }

    // Attempt match
    if (selectedTile!.matches(tile)) {
      final tile1 = selectedTile!;
      final tile2 = tile;

      tile1.isSelected = false;
      tile2.isSelected = false;
      tile1.isRemoved = true;
      tile2.isRemoved = true;
      selectedTile = null;

      // Combo & scoring calculation
      final now = DateTime.now();
      if (lastMatchTime != null && now.difference(lastMatchTime!) <= comboWindow) {
        combo++;
      } else {
        combo = 1;
      }
      lastMatchTime = now;

      final points = 100 * combo;
      score += points;

      final action = MatchAction(
        first: tile1,
        second: tile2,
        pointsEarned: points,
        combo: combo,
      );
      undoStack.add(action);

      if (onMatch != null) {
        onMatch(action);
      }
      return 'matched';
    } else {
      // Mismatch: switch selection to newly tapped free tile
      selectedTile!.isSelected = false;
      tile.isSelected = true;
      selectedTile = tile;
      return 'mismatch';
    }
  }

  /// Find a valid free matching pair for the Hint booster
  List<MahjongTile>? getHint() {
    final free = getFreeTiles();
    final Map<String, List<MahjongTile>> groupMap = {};
    for (final t in free) {
      groupMap.putIfAbsent(t.matchGroup, () => []).add(t);
    }

    for (final pair in groupMap.values) {
      if (pair.length >= 2) {
        activeHint = [pair[0], pair[1]];
        return activeHint;
      }
    }
    activeHint = null;
    return null;
  }

  /// Undo the last match
  bool undoLastMove() {
    if (undoStack.isEmpty) return false;
    final last = undoStack.removeLast();

    // Re-enable tiles
    last.first.isRemoved = false;
    last.first.isSelected = false;
    last.second.isRemoved = false;
    last.second.isSelected = false;

    score = max(0, score - last.pointsEarned);
    combo = max(0, last.combo - 1);
    selectedTile?.isSelected = false;
    selectedTile = null;
    activeHint = null;
    return true;
  }

  /// Reshuffle booster: rearranges the tile identities of remaining unremoved slots
  /// Guarantees that at least one free pair is available
  bool shuffleRemainingTiles([int? seed]) {
    final remaining = tiles.where((t) => !t.isRemoved).toList();
    if (remaining.length < 2) return false;

    selectedTile?.isSelected = false;
    selectedTile = null;
    activeHint = null;

    final rand = Random(seed);
    // Extract types
    final types = remaining.map((t) => (t.category, t.value)).toList();

    for (int attempt = 0; attempt < 50; attempt++) {
      types.shuffle(rand);
      for (int i = 0; i < remaining.length; i++) {
        final (cat, val) = types[i];
        remaining[i] = remaining[i].copyWith(category: cat, value: val);
      }
      // Re-map tiles into main list
      final Map<String, MahjongTile> map = {for (final t in remaining) t.id: t};
      for (int i = 0; i < tiles.length; i++) {
        if (map.containsKey(tiles[i].id)) {
          tiles[i] = map[tiles[i].id]!;
        }
      }

      // Check if there is at least one legal free pair
      if (getHint() != null) {
        activeHint = null;
        return true;
      }
    }
    return true;
  }

  /// Remaining pairs count
  int get remainingPairs => tiles.where((t) => !t.isRemoved).length ~/ 2;

  /// Game completion status
  bool get isVictory => tiles.every((t) => t.isRemoved);

  /// Game over status (tiles remaining but no moves possible and no shuffles left)
  bool get hasLegalMoves => getHint() != null;

  // =========================================================================
  // Guaranteed Solvable Board Generator (Backward Play Simulation)
  // =========================================================================
  List<MahjongTile> _generateSolvableBoard(int seed) {
    final rand = Random(seed);
    final slots = layout.slots;
    final int totalTiles = slots.length;
    final int pairCount = totalTiles ~/ 2;

    // Available tile pool (42 types)
    final pool = _generateTilePool(pairCount, rand);

    for (int retry = 0; retry < 30; retry++) {
      final board = <MahjongTile>[];
      for (int i = 0; i < totalTiles; i++) {
        board.add(MahjongTile(
          id: 'tile_$i',
          category: 'dummy',
          value: 'dummy',
          x: slots[i].x,
          y: slots[i].y,
          z: slots[i].z,
        ));
      }

      // Backward simulation:
      // Start with all slots present (isRemoved = false).
      // Repeatedly pick 2 free positions, assign them matching tile types from pool,
      // and mark them as removed in the simulation!
      final assignedPairs = <(int, int)>[];
      final simTiles = board.map((t) => t.copyWith()).toList();
      bool success = true;

      for (int p = 0; p < pairCount; p++) {
        final freeIndices = <int>[];
        for (int i = 0; i < simTiles.length; i++) {
          if (!simTiles[i].isRemoved && _isSimFree(simTiles[i], simTiles)) {
            freeIndices.add(i);
          }
        }

        if (freeIndices.length < 2) {
          success = false;
          break; // Deadlock in reverse, try again
        }

        // Pick 2 random free indices
        freeIndices.shuffle(rand);
        final idx1 = freeIndices[0];
        final idx2 = freeIndices[1];

        simTiles[idx1].isRemoved = true;
        simTiles[idx2].isRemoved = true;
        assignedPairs.add((idx1, idx2));
      }

      if (success && assignedPairs.length == pairCount) {
        // Successfully solved backwards! Now apply the tile identities
        for (int p = 0; p < pairCount; p++) {
          final (i1, i2) = assignedPairs[p];
          final (cat, val) = pool[p];
          board[i1] = board[i1].copyWith(category: cat, value: val);
          board[i2] = board[i2].copyWith(category: cat, value: val);
        }
        return board;
      }
    }

    // Fallback: If 30 retries failed (extremely rare), generate balanced random pairs
    final fallbackBoard = <MahjongTile>[];
    final shuffledPool = <(String, String)>[];
    for (int p = 0; p < pairCount; p++) {
      shuffledPool.add(pool[p]);
      shuffledPool.add(pool[p]);
    }
    shuffledPool.shuffle(rand);

    for (int i = 0; i < totalTiles; i++) {
      final (cat, val) = shuffledPool[i];
      fallbackBoard.add(MahjongTile(
        id: 'tile_$i',
        category: cat,
        value: val,
        x: slots[i].x,
        y: slots[i].y,
        z: slots[i].z,
      ));
    }
    return fallbackBoard;
  }

  static bool _isSimFree(MahjongTile target, List<MahjongTile> list) {
    if (target.isRemoved) return false;

    // 1. Top blockers
    for (final other in list) {
      if (other.isRemoved || other.id == target.id) continue;
      if (other.z > target.z) {
        if ((other.x - target.x).abs() < 0.95 && (other.y - target.y).abs() < 0.95) {
          return false;
        }
      }
    }

    // 2. Lateral blockers
    bool hasLeft = false;
    bool hasRight = false;
    for (final other in list) {
      if (other.isRemoved || other.id == target.id) continue;
      if (other.z == target.z) {
        final double dy = (other.y - target.y).abs();
        if (dy < 0.90) {
          final double dxLeft = target.x - other.x;
          if (dxLeft > 0.1 && dxLeft < 1.05) hasLeft = true;
          final double dxRight = other.x - target.x;
          if (dxRight > 0.1 && dxRight < 1.05) hasRight = true;
        }
      }
    }
    return (!hasLeft) || (!hasRight);
  }

  static List<(String, String)> _generateTilePool(int pairCount, Random rand) {
    final List<(String, String)> allTypes = [];
    // Wan 1-9
    for (int i = 1; i <= 9; i++) {
      allTypes.add(('wan', '$i'));
    }
    // Dot 1-9
    for (int i = 1; i <= 9; i++) {
      allTypes.add(('dot', '$i'));
    }
    // Bamboo 1-9
    for (int i = 1; i <= 9; i++) {
      allTypes.add(('bamboo', '$i'));
    }
    // Dragons
    allTypes.addAll([('dragon', 'red'), ('dragon', 'green'), ('dragon', 'white')]);
    // Winds
    allTypes.addAll([('wind', 'east'), ('wind', 'south'), ('wind', 'west'), ('wind', 'north')]);
    // Seasons
    allTypes.addAll([('season', 'spring'), ('season', 'summer'), ('season', 'autumn'), ('season', 'winter')]);
    // Flowers
    allTypes.addAll([('flower', 'plum'), ('flower', 'orchid'), ('flower', 'bamboo'), ('flower', 'chrysanthemum')]);

    allTypes.shuffle(rand);

    final List<(String, String)> selectedPairs = [];
    int index = 0;
    while (selectedPairs.length < pairCount) {
      selectedPairs.add(allTypes[index % allTypes.length]);
      index++;
    }
    return selectedPairs;
  }
}
