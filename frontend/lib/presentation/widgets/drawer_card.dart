import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'custom_switch.dart';

class DrawerCard extends StatefulWidget {
  final VoidCallback onClose;

  const DrawerCard({super.key, required this.onClose});

  @override
  State<DrawerCard> createState() => _DrawerCardState();
}

class _DrawerCardState extends State<DrawerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 220,
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: themeProvider.isDarkTheme ? Color(0xFF303030) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.18 * 255).round()),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with close button — уже готов у тебя
            Align(
              alignment: Alignment.topRight,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF898989), width: 1),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Color(0xFF898989),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Dark mode toggle row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: CustomSwitch(
                    value: themeProvider.isDarkTheme,
                    onChanged: (_) => themeProvider.changeTheme(),
                  ),
                ),
              ],
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 1),
            ),

            // How to use
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                "How to use",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Color(0xFF898989),
              ),
              onTap: () {
                // Future use
              },
            ),

            const Divider(height: 1, thickness: 1), // нижняя черта
          ],
        ),
      ),
    );
  }
}
