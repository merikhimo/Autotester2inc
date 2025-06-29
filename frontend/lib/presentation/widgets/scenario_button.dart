import 'package:flutter/material.dart';
import 'package:inno_test/domain/enums/test_variant_type.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ScenarioButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final TestVariantType type;

  const ScenarioButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.type,
  });

  @override
  State<ScenarioButton> createState() => _ScenarioButtonState();
}

class _ScenarioButtonState extends State<ScenarioButton> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() => _isTapped = true);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _isTapped = false);

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Цвет по умолчанию
    final Color baseColor = themeProvider.isDarkTheme
        ? const Color(0xFF898989)
        : const Color(0xFFF5F5F5);

    // Цвет во время мигания
    final Color tapColor =
        const Color(0xFFBEBEBE); // ← тот самый серый как на скрине

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isTapped ? tapColor : baseColor,
            borderRadius: BorderRadius.circular(50),
          ),
          width: 90,
          height: 30,
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: themeProvider.isDarkTheme
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFF898989)),
          ),
        ),
      ),
    );
  }
}
