import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mahjong/models/mahjong_layout.dart';
import 'package:nova_mahjong/logic/mahjong_engine.dart';

void main() {
  test('Turtle layout generation and hint verification', () {
    final layout = MahjongLayout.turtle();
    final engine = MahjongEngine(layout: layout);
    expect(engine.tiles.length, 144);
    final free = engine.getFreeTiles();
    expect(free.isNotEmpty, true);
    final hint = engine.getHint();
    expect(hint, isNotNull);
  });
}
