import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/presentation/pages/home_page.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomePage shows input and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(
              create: (_) => TestProvider(InMemoryTestRepository())),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Paste link'), findsOneWidget);
    expect(find.text('Existence'), findsOneWidget);
    expect(find.text('Correctness'), findsOneWidget);
    expect(find.text('Clickability'), findsOneWidget);
  });
}
