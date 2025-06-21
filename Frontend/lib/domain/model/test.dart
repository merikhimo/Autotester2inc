class Test {
  final String testName;
  final String id;

  Test({required this.testName, required this.id});

  @override
  String toString() {
    return testName;
  }
}

class TestResult {
  final String test;
  final bool result;

  TestResult({required this.test, required this.result});
}
