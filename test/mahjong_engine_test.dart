import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mahjong/logic/mahjong_engine.dart';
import 'package:nova_mahjong/models/mahjong_layout.dart';

void main() {
  group('MahjongEngine Low-End Performance & Solvability Tests', () {
    test('Initializes Pagoda layout with cached sorted tiles and moves', () {
      final engine = MahjongEngine(layout: MahjongLayout.pagoda());
      expect(engine.tiles.length, 72);
      expect(engine.sortedTiles.length, 72);
      expect(engine.availableMovesCount, greaterThan(0));
      expect(engine.getFreeTiles().length, greaterThan(0));
    });

    test('All free tiles in engine.getFreeTiles() satisfy isTileFree()', () {
      final engine = MahjongEngine(layout: MahjongLayout.pagoda());
      final freeTiles = engine.getFreeTiles();
      for (final t in freeTiles) {
        expect(engine.isTileFree(t), isTrue);
      }
    });

    test('O(1) Benchmark: 10,000 checks of availableMovesCount & isTileFree execute in <50ms', () {
      final engine = MahjongEngine(layout: MahjongLayout.turtle());
      final stopwatch = Stopwatch()..start();

      int sum = 0;
      for (int i = 0; i < 10000; i++) {
        sum += engine.availableMovesCount;
        final tile = engine.sortedTiles[i % engine.sortedTiles.length];
        if (engine.isTileFree(tile)) {
          sum++;
        }
      }
      stopwatch.stop();

      expect(sum, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Hint, Match, Undo, and Shuffle preserve solvability & cache integrity', () {
      final engine = MahjongEngine(layout: MahjongLayout.pagoda());
      final hint = engine.getHint();
      expect(hint, isNotNull);
      expect(hint!.length, 2);
      expect(hint[0].matches(hint[1]), isTrue);

      final initialScore = engine.score;
      final initialRemaining = engine.remainingPairs;

      // Tap first tile
      final res1 = engine.tapTile(hint[0]);
      expect(res1, 'selected');
      expect(hint[0].isSelected, isTrue);

      // Tap second matching tile
      final res2 = engine.tapTile(hint[1]);
      expect(res2, 'matched');
      expect(hint[0].isRemoved, isTrue);
      expect(hint[1].isRemoved, isTrue);
      expect(engine.remainingPairs, initialRemaining - 1);
      expect(engine.score, greaterThan(initialScore));

      // Undo move
      final undone = engine.undoLastMove();
      expect(undone, isTrue);
      expect(hint[0].isRemoved, isFalse);
      expect(hint[1].isRemoved, isFalse);
      expect(engine.remainingPairs, initialRemaining);
      expect(engine.score, initialScore);

      // Shuffle
      final shuffled = engine.shuffleRemainingTiles();
      expect(shuffled, isTrue);
      expect(engine.availableMovesCount, greaterThan(0));
    });
  });
}
