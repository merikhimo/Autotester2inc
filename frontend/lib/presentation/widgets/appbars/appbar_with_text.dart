import 'package:flutter/material.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:provider/provider.dart';

import '../../pages/home_page.dart';
import '../../providers/theme_provider.dart';

class AppbarWithText extends StatelessWidget {
  final String text;

  const AppbarWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final testProvider = Provider.of<TestProvider>(context);

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
            GestureDetector(
              onTap: () {
                testProvider.removeAllTests();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            size: 17,
                            color: Color(0xFF898989),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            text,
                            style: const TextStyle(
                              color: Color(0xFF898989),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
