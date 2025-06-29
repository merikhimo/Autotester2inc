import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../drawer_card.dart';
import '../info_card.dart';
import '../overlay_card.dart';

class AppBarHomePage extends StatefulWidget {
  const AppBarHomePage({super.key});

  @override
  State<AppBarHomePage> createState() => _AppBarHomePageState();
}

class _AppBarHomePageState extends State<AppBarHomePage> {
  double? _lastWindowWidth;
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey drawerKey = GlobalKey();
  OverlayEntry? aboutOverlayEntry;

  void _removeOverlay() {
    aboutOverlayEntry?.remove();
    aboutOverlayEntry = null;
  }

  void _showOverlay({required Offset position, required Widget content}) {
    _removeOverlay();

    final overlay = Overlay.of(context);

    aboutOverlayEntry = OverlayEntry(
      builder: (context) => OverlayCard(
        position: position,
        onClose: _removeOverlay,
        child: content,
      ),
    );

    overlay.insert(aboutOverlayEntry!);
  }

  void _toggleOverlay(GlobalKey key, Widget contentBuilder) {
    if (aboutOverlayEntry != null) {
      _removeOverlay();
      return;
    }

    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    aboutOverlayEntry = OverlayEntry(
      builder: (context) => OverlayCard(
        position: Offset(position.dx - 170, position.dy + 40), // Сдвиг влево
        onClose: _removeOverlay,
        child: contentBuilder,
      ),
    );

    overlay.insert(aboutOverlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = MediaQuery.of(context).size.width;

        if (_lastWindowWidth != null && _lastWindowWidth != currentWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _removeOverlay();
          });
        }

        _lastWindowWidth = currentWidth;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(50, 30, 50, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Inno Test",
                  style: TextStyle(
                    color:
                        themeProvider.isDarkTheme ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: aboutKey,
                      onTap: () {
                        if (aboutOverlayEntry != null) {
                          _removeOverlay();
                          return;
                        }

                        final RenderBox renderBox = aboutKey.currentContext!
                            .findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);

                        _showOverlay(
                          position:
                              Offset(position.dx, position.dy + 10), // было +30
                          content: InfoCard(onClose: _removeOverlay),
                        );
                      },
                      child: const Text(
                        "About",
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  key: drawerKey,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.menu, // <-- Drawer icon
                        size: 25,
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      if (aboutOverlayEntry != null) {
                        _removeOverlay();
                        return;
                      }

                      final RenderBox renderBox = drawerKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final position = renderBox.localToGlobal(Offset.zero);

                      _showOverlay(
                        position: Offset(
                            position.dx - 220, position.dy + 40), // ← было -170
                        content: DrawerCard(onClose: _removeOverlay),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
