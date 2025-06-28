import 'package:flutter/material.dart';
import 'package:inno_test/data/repositories/test_repository.dart';

import '../../domain/model/test.dart';

class TestProvider extends ChangeNotifier {
  final TestRepository testRepository;

  List<TestResult> _results = [];
  List<TestResult> get results => _results;

  TestProvider(this.testRepository);

  Future<void> runTests(String url, List<String> tests) async {
    _results = await testRepository.sendUrlForScan(url: url, tests: tests);
    notifyListeners();
  }

  List<Test> getTests() {
    return testRepository.getTests();
  }

  void addTest(Test test) {
    testRepository.addTest(test);
    notifyListeners();
  }

  void removeTest(String id) {
    testRepository.removeTest(id);
    notifyListeners();
  }

  void removeAllTests() {
    testRepository.removeAllTests();
    notifyListeners();
  }
}
