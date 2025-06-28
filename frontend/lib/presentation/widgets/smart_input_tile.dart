import 'package:flutter/material.dart';
import 'package:inno_test/domain/enums/test_variant_type.dart';
import 'package:provider/provider.dart';

import '../../domain/model/test.dart';
import '../providers/test_provider.dart';
import '../providers/theme_provider.dart';

class SmartInputTile extends StatefulWidget {
  final String id;
  final VoidCallback onDelete;
  final TestVariantType type;

  const SmartInputTile(
      {super.key,
      required this.onDelete,
      required this.id,
      required this.type});

  @override
  State<SmartInputTile> createState() => _SmartInputTileState();
}

class _SmartInputTileState extends State<SmartInputTile> {
  final TextEditingController _controller = TextEditingController();
  bool isEditing = true;
  String text = '';
  double _inputWidth = 150;
  double _submittedWidth = 500;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_calculateInputWidth);
    _calculateInputWidth(); // initial width
  }

  void _calculateInputWidth() {
    final measured = _controller.text.isEmpty ? '...' : _controller.text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: measured,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 250); // don't overflow

    setState(() {
      _inputWidth = textPainter.width + 150;
    });
  }

  bool _submit() {
    if (_controller.text.trim().isEmpty) return false;
    setState(() {
      text = _controller.text.trim();
      isEditing = false;
      _submittedWidth = _inputWidth.clamp(150, 287);
    });
    return true;
  }

  void _editAgain() {
    _controller.text = text;
    setState(() {
      isEditing = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: !isEditing
          ? () {
              _editAgain();
              testProvider.removeTest(widget.id);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isEditing ? _inputWidth.clamp(150, 287) : _submittedWidth,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isEditing
                    ? (themeProvider.isDarkTheme
                        ? const Color(0xFF303030)
                        : const Color(0xFFF5F5F5))
                    : const Color(0xFFCAE5FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: isEditing
                  ? Row(
                      children: [
                        Text(
                          widget.type == TestVariantType.existence
                              ? "Does "
                              : "Is ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            cursorColor: const Color(0xFF0088FF),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: '...',
                              hintStyle: TextStyle(
                                color: Color(0xFFB2B2B2),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onSubmitted: (_) {
                              if (_submit()) {
                                testProvider.addTest(Test(
                                  testName: _controller.text.trim(),
                                  id: widget.id,
                                ));
                              }
                            },
                          ),
                        ),
                        Text(
                          widget.type == TestVariantType.existence
                              ? " exist?"
                              : " clickable?",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_submit()) {
                              testProvider.addTest(Test(
                                testName: _controller.text.trim(),
                                id: widget.id,
                              ));
                            }
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0285FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        widget.type == TestVariantType.existence
                            ? "Does $text exist?"
                            : "Is $text clickable?",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (!isEditing) {
                  testProvider.removeTest(widget.id);
                }
                widget.onDelete();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  alignment: Alignment.center,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkTheme
                        ? const Color(0xFF898989)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: themeProvider.isDarkTheme
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFFB2B2B2),
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
