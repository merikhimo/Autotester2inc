import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/widgets/appbars/appbar_home_page.dart';
import 'package:inno_test/presentation/widgets/test_tile.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'loading_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<String> _tiles = [];
  bool _isUrlInvalid = false;

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(_animationController);

    textEditingController.addListener(() {
      if (textEditingController.text.isEmpty && _isUrlInvalid) {
        setState(() {
          _isUrlInvalid = false;
        });
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void errorInUrl() {
    setState(() {
      _isUrlInvalid = true;
    });
    _animationController.forward(from: 0);
  }

  Future<void> sendUrl(TestProvider testProvider) async {
    final url = textEditingController.text.trim();

    if (url.isEmpty || _tiles.isEmpty) {
      errorInUrl();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://31.129.111.114:808/api/checkurl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LoadingPage(
            url: url,
            tests: testProvider.getTests().map((e) => e.testName).toList(),
          ),
        ));
      } else {
        errorInUrl();
      }
    } catch (e) {
      errorInUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final testProvider = Provider.of<TestProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), child: AppBarHomePage()),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  Text(
                    "Hello, what are we testing today?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth > 500
                          ? 500
                          : constraints.maxWidth * 0.9;

                      return AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                                _isUrlInvalid ? _shakeAnimation.value : 0, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          width: maxWidth,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkTheme
                                ? const Color(0xFF303030)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _isUrlInvalid
                                  ? const Color(0xFFFF383C)
                                  : Colors.transparent,
                              width: 0.8,
                            ),
                          ),
                          child: TextFormField(
                            onFieldSubmitted: (text) {
                              sendUrl(testProvider);
                            },
                            cursorColor: Colors.black,
                            controller: textEditingController,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              hintStyle: const TextStyle(
                                  color: Color(0xFF898989),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter"),
                              hintText: "Paste link",
                              border: InputBorder.none,
                              icon: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: themeProvider.isDarkTheme
                                        ? const Color(0xFF898989)
                                        : const Color(0xFFD9D9D9),
                                    shape: BoxShape.circle),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.image,
                                    color: themeProvider.isDarkTheme
                                        ? const Color(0xFFF5F5F5)
                                        : const Color(0xFFF5F5F5),
                                  ),
                                ),
                              ),
                              suffixIcon: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF0088FF),
                                    shape: BoxShape.circle),
                                child: IconButton(
                                  onPressed: () {
                                    sendUrl(testProvider);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: _tiles.map((tileId) {
                        return TestTile(
                          key: ValueKey(tileId),
                          id: tileId,
                          onDelete: () {
                            setState(() {
                              _tiles.removeWhere((e) => e == tileId);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 140),
                    child: GestureDetector(
                      onTap: () {
                        var id =
                            DateTime.now().microsecondsSinceEpoch.toString();

                        setState(() {
                          if (testProvider.getTests().length == _tiles.length) {
                            _tiles.add(id);
                          }
                        });

                        Future.delayed(Duration(milliseconds: 100), () {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: themeProvider.isDarkTheme
                                  ? Color(0xFF898989)
                                  : Color(0xFFF5F5F5),
                              shape: BoxShape.circle),
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          child: Icon(
                            size: 25,
                            Icons.add,
                            color: themeProvider.isDarkTheme
                                ? Color(0xFFF5F5F5)
                                : Color(0xFFB2B2B2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: 50),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _tiles.length <= 0
                  ? Text("")
                  : GestureDetector(
                      onTap: () {
                        print(testProvider.getTests());

                        testProvider.removeAllTests();
                        setState(() {
                          _tiles.clear();
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: themeProvider.isDarkTheme
                                  ? Color(0xFF303030)
                                  : Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(45)),
                          width: 193,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              const Text(
                                'Delete all tests',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          )),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
