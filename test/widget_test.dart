import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadboard/main.dart';

void main() {
  testWidgets('shows firebase setup when not configured', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SquadBoardApp()));
    expect(find.text('Firebase not configured'), findsOneWidget);
  });
}
