import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/model/test.dart';
import '../providers/test_provider.dart';
import '../providers/theme_provider.dart';

class AttributeCheckTile extends StatefulWidget {
  final String id;
  final VoidCallback onDelete;

  const AttributeCheckTile(
      {super.key, required this.id, required this.onDelete});

  @override
  State<AttributeCheckTile> createState() => _AttributeCheckTileState();
}

class _AttributeCheckTileState extends State<AttributeCheckTile> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _attributeController = TextEditingController();

  bool isEditing = true;
  String submittedText = '';
  double _containerWidth = 350;

  bool _submit() {
    final type = _typeController.text.trim();
    final attr = _attributeController.text.trim();

    if (type.isEmpty || attr.isEmpty) return false;

    setState(() {
      submittedText = "Is there a $type with $attr?";
      isEditing = false;
    });

    return true;
  }

  void _editAgain() {
    setState(() {
      isEditing = true;
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _attributeController.dispose();
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
              width: _containerWidth,
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
                        const Text(
                          "Is there a ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Flexible(
                          child: TextField(
                            controller: _typeController,
                            cursorColor: const Color(0xFF0088FF),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'element type',
                              hintStyle: TextStyle(
                                color: Color(0xFFB2B2B2),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          " with ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Flexible(
                          child: TextField(
                            controller: _attributeController,
                            cursorColor: const Color(0xFF0088FF),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'attribute/value',
                              hintStyle: TextStyle(
                                color: Color(0xFFB2B2B2),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onSubmitted: (_) {
                              if (_submit()) {
                                testProvider.addTest(Test(
                                  testName: submittedText,
                                  id: widget.id,
                                ));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_submit()) {
                              testProvider.addTest(Test(
                                testName: submittedText,
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
                        submittedText,
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
