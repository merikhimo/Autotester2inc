import 'package:flutter/material.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/data/repositories/test_repository.dart';
import 'package:inno_test/presentation/pages/home_page.dart';
import 'package:inno_test/presentation/pages/welcome_page.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:inno_test/presentation/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final alreadyVisited = prefs.getBool('instructions_shown') ?? false;

  final TestRepository testRepository = InMemoryTestRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TestProvider(testRepository),
        )
      ],
      child: MyApp(initiallyVisited: alreadyVisited),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool initiallyVisited;

  const MyApp({super.key, required this.initiallyVisited});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: widget.initiallyVisited ? const HomePage() : const WelcomePage(),
    );
  }
}
