import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/presentation/pages/home_page.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomePage loads and shows input', (WidgetTester tester) async {
    final testRepository = InMemoryTestRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TestProvider(testRepository)),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Paste link'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });
}
