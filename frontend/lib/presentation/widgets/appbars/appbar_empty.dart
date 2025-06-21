import 'package:flutter/material.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AppbarEmpty extends StatelessWidget {
  const AppbarEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30),
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Inno Test",
                  style: TextStyle(
                    color:
                        themeProvider.isDarkTheme ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
