import 'package:flutter/material.dart';
import 'package:inno_test/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int currentStep = 0;

  final List<_StepContent> steps = [
    _StepContent(
      image: 'assets/images/url_send.png',
      text: 'First, paste website link that you want to test',
    ),
    _StepContent(
      image: 'assets/images/variants.png',
      text:
          'Then choose the test you need. Each variant \nrepresents one the available scenario',
    ),
    _StepContent(
      image: 'assets/images/exist.png',
      text: 'And fill the template. It can be specific\nbutton or function',
    ),
  ];

  Future<void> _goToHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('instructions_shown', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _goToHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset('assets/images/handshaking.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome to Inno Test",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Here you can test any website",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 30),
            Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          Image.asset(
                            step.image,
                            width: 300,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            step.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _nextStep,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          width: currentStep < steps.length - 1 ? 75 : 107,
                          height: 30,
                          child: Text(
                            currentStep < steps.length - 1
                                ? 'Next'
                                : "Let's start",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent {
  final String image;
  final String text;

  const _StepContent({
    required this.image,
    required this.text,
  });
}
