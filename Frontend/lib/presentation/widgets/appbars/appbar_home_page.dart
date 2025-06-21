import 'package:flutter/material.dart';
import 'package:inno_test/presentation/widgets/info_card.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class AppBarHomePage extends StatefulWidget {
  const AppBarHomePage({super.key});

  @override
  State<AppBarHomePage> createState() => _AppBarHomePageState();
}

class _AppBarHomePageState extends State<AppBarHomePage> {
  double? _lastWindowWidth;
  final GlobalKey aboutKey = GlobalKey();
  OverlayEntry? aboutOverlayEntry;

  void _removeOverlay() {
    aboutOverlayEntry?.remove();
    aboutOverlayEntry = null;
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
                  margin: EdgeInsets.only(right: 50),
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
                        final overlay = Overlay.of(context);

                        aboutOverlayEntry = OverlayEntry(
                          builder: (context) => GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _removeOverlay,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: position.dx,
                                  top: position.dy + 30,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InfoCard(onClose: _removeOverlay),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        overlay.insert(aboutOverlayEntry!);
                      },
                      child: Text(
                        "About",
                        style: TextStyle(
                          color: const Color(0xFF737373),
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkTheme
                        ? const Color(0xFFC3E0FE)
                        : const Color(0xFFF3F3F3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          themeProvider.isDarkTheme ? Colors.blue : Colors.grey,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      themeProvider.isDarkTheme
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 20,
                      color: themeProvider.isDarkTheme
                          ? const Color(0xFF027AFE)
                          : const Color(0xFF7E7E7E),
                    ),
                    onPressed: () {
                      themeProvider.changeTheme();
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
