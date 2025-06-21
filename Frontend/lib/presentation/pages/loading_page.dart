import 'package:flutter/material.dart';
import 'package:inno_test/presentation/pages/result_page.dart';
import 'package:inno_test/presentation/widgets/appbars/appbar_empty.dart';
import 'package:inno_test/presentation/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/test_provider.dart';
import '../providers/theme_provider.dart';

class LoadingPage extends StatefulWidget {
  final String url;
  final List<String> tests;

  const LoadingPage({super.key, required this.tests, required this.url});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _startTest();
  }

  Future<void> _startTest() async {
    try {
      await Provider.of<TestProvider>(context, listen: false)
          .runTests(widget.url, widget.tests);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), child: AppbarEmpty()),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
              ),
              LoadingIndicator(),
              SizedBox(
                height: 400,
              ),
              Text(
                "Can take a minute",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              )
            ],
          ),
        ),
      ),
    );
  }
}
