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
      onTap: !isEditing ? _editAgain : null,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isEditing
                    ? (themeProvider.isDarkTheme
                        ? const Color(0xFF303030)
                        : const Color(0xFFF5F5F5))
                    : const Color(0xFFCAE5FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Does ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  if (isEditing)
                    SizedBox(
                      width: 165,
                      child: TextField(
                        controller: controller,
                        onSubmitted: (_) {
                          if (_submit()) {
                            testProvider.addTest(Test(
                              testName: controller.text.trim(),
                              id: widget.id,
                            ));
                          }
                        },
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: "...",
                          hintStyle: TextStyle(
                            color: Color(0xFF898989),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const Text(
                    ' exist?',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_submit()) {
                        testProvider.addTest(Test(
                          testName: controller.text.trim(),
                          id: widget.id,
                        ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0285FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
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
          ],
        ),
      ),
    );
  }
}
