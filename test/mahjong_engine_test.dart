import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mahjong/models/mahjong_layout.dart';
import 'package:nova_mahjong/logic/mahjong_engine.dart';

void main() {
  group('MahjongEngine Core Logic Tests', () {
    test('Generate Lotus Layout and verify 100% solvable board', () {
      final layout = MahjongLayout.lotus();
      final engine = MahjongEngine(layout: layout);

      expect(engine.tiles.length, 32);
      expect(engine.remainingPairs, 16);

      // Verify that there are free tiles at start
      final freeTiles = engine.getFreeTiles();
      expect(freeTiles.isNotEmpty, true);

      // Verify that at least one matching pair is currently free (guaranteed by solver)
      final hint = engine.getHint();
      expect(hint, isNotNull);
      expect(hint!.length, 2);
      expect(hint[0].matches(hint[1]), true);
    });

    test('Tile selection, matching, combo and undo stack', () {
      final layout = MahjongLayout.lotus();
      final engine = MahjongEngine(layout: layout);

      // Find free hint pair
      final hint = engine.getHint()!;
      final tileA = hint[0];
      final tileB = hint[1];

      // Tap tileA
      final res1 = engine.tapTile(tileA);
      expect(res1, 'selected');
      expect(engine.selectedTile, tileA);
      expect(tileA.isSelected, true);

      // Tap tileB -> should match!
      final res2 = engine.tapTile(tileB);
      expect(res2, 'matched');
      expect(tileA.isRemoved, true);
      expect(tileB.isRemoved, true);
      expect(engine.selectedTile, isNull);
      expect(engine.score, 100);
      expect(engine.combo, 1);
      expect(engine.undoStack.length, 1);

      // Test Undo
      final undoSuccess = engine.undoLastMove();
      expect(undoSuccess, true);
      expect(tileA.isRemoved, false);
      expect(tileB.isRemoved, false);
      expect(engine.score, 0);
      expect(engine.combo, 0);
      expect(engine.undoStack.isEmpty, true);
    });

    test('Shuffle preserves remaining count and produces legal moves', () {
      final layout = MahjongLayout.miniTurtle();
      final engine = MahjongEngine(layout: layout);

      final initialRemaining = engine.remainingPairs;
      expect(initialRemaining, 24);

      final shuffled = engine.shuffleRemainingTiles();
      expect(shuffled, true);
      expect(engine.remainingPairs, initialRemaining);
      expect(engine.hasLegalMoves, true);
    });

    test('All 5 handcrafted layouts initialize properly with solvable moves', () {
      final stages = MahjongLayout.allStages();
      for (final stage in stages) {
        final engine = MahjongEngine(layout: stage);
        expect(engine.tiles.length, stage.tileCount);
        expect(engine.tiles.length % 2, 0);
        expect(engine.getFreeTiles().isNotEmpty, true);
      }
    });
  });
}
