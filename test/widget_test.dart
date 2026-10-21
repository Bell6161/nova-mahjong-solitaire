import 'package:flutter_test/flutter_test.dart';
import 'package:nova_mahjong/main.dart';
import 'package:nova_mahjong/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('NovaMahjongApp builds and renders HUD', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaMahjongApp());
    // Pump single frame for initial render with repeating animations
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('The Classic Turtle'), findsOneWidget);
    expect(find.text('Hint'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });
}
