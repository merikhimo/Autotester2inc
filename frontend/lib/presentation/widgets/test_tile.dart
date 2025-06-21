import 'package:flutter/material.dart';
import 'package:inno_test/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../domain/model/test.dart';
import '../providers/test_provider.dart';

class TestTile extends StatefulWidget {
  final String id;
  final VoidCallback onDelete;

  const TestTile({super.key, required this.onDelete, required this.id});

  @override
  State<TestTile> createState() => _TestTileState();
}

class _TestTileState extends State<TestTile> {
  bool isEditing = true;
  String text = '';
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _submit() {
    if (controller.text.trim().isEmpty) return false;
    setState(() {
      text = controller.text.trim();
      isEditing = false;
    });
    return true;
  }

  void _editAgain() {
    controller.text = text;
    setState(() {
      isEditing = true;
    });
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
        margin: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              alignment: Alignment.center,
              width: 275,
              height: 50,
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isEditing
                    ? (themeProvider.isDarkTheme
                        ? Color(0xFF303030)
                        : Color(0xFFF5F5F5))
                    : Color(0xFFCAE5FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: isEditing
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (text) {
                              if (_submit()) {
                                Test test = Test(
                                    testName: controller.text.trim(),
                                    id: widget.id);
                                testProvider.addTest(test);
                              }
                            },
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                            cursorColor: Colors.black,
                            controller: controller,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              hintText: 'Describe your test',
                              hintStyle: TextStyle(
                                  color: Color(0xFF898989),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
                              if (_submit()) {
                                Test test = Test(
                                    testName: controller.text.trim(),
                                    id: widget.id);
                                testProvider.addTest(test);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0285FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            SizedBox(
              width: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (isEditing == false) {
                    testProvider.removeTest(widget.id);
                  }
                  widget.onDelete();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: themeProvider.isDarkTheme
                          ? Color(0xFF898989)
                          : Color(0xFFF5F5F5),
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: themeProvider.isDarkTheme
                        ? Color(0xFFF5F5F5)
                        : Color(0xFFB2B2B2),
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
