import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  int activeDot = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        activeDot = (activeDot + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget buildDot(int index, Color dotColor) {
    return AnimatedOpacity(
      opacity: activeDot == index ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dotColor,
        ),
        width: 10,
        height: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Processing",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
        ),
        const SizedBox(width: 10),
        buildDot(0, themeProvider.isDarkTheme ? Colors.white : Colors.black),
        const SizedBox(width: 5),
        buildDot(1, themeProvider.isDarkTheme ? Colors.white : Colors.black),
        const SizedBox(width: 5),
        buildDot(2, themeProvider.isDarkTheme ? Colors.white : Colors.black),
      ],
    );
  }
}
