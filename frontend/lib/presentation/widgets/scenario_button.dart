import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ScenarioButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isSelected;

  const ScenarioButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFCAE5FF)
                : themeProvider.isDarkTheme
                    ? const Color(0xFF898989)
                    : const Color(0xFFF5F5F5),
            border: Border.all(
              width: 0.5,
              color: isSelected
                  ? const Color(0xFF0285FF)
                  : themeProvider.isDarkTheme
                      ? const Color(0xFFB2B2B2)
                      : const Color(0xFFBABABA),
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          width: 120,
          height: 35,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              letterSpacing: 1,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: isSelected
                  ? const Color(0xFF0285FF)
                  : themeProvider.isDarkTheme
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF898989),
            ),
          ),
        ),
      ),
    );
  }
}
