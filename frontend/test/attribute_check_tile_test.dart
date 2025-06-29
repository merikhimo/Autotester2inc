import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:inno_test/presentation/widgets/attribute_check_tile.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AttributeCheckTile creates test on submit',
      (WidgetTester tester) async {
    final testRepository = InMemoryTestRepository();
    final testProvider = TestProvider(testRepository);

    bool deleteCalled = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<TestProvider>.value(value: testProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AttributeCheckTile(
              id: '123',
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'button');
    await tester.enterText(find.byType(TextField).at(1), 'color="blue"');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    final addedTests = testProvider.getTests();
    expect(addedTests.length, 1);
    expect(addedTests.first.testName, 'Is there a button with color="blue"?');
    expect(addedTests.first.id, '123');
  });
}
