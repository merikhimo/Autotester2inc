import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/data/repositories/test_repository.dart';
import 'package:inno_test/presentation/pages/welcome_page.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:inno_test/presentation/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WelcomePage goes through steps and opens HomePage',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final TestRepository testRepository = InMemoryTestRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TestProvider(testRepository)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const WelcomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Step 1
    expect(find.text('First, paste website link that you want to test'),
        findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2
    expect(
        find.textContaining('Then choose the test you need'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3
    expect(find.textContaining('And fill the template'), findsOneWidget);
    await tester.tap(find.text("Let's start"));
    await tester.pumpAndSettle();
  });
}
