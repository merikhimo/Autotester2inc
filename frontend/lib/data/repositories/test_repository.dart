import 'package:inno_test/domain/model/test.dart';

abstract class TestRepository {
  List<Test> getTests();
  void addTest(Test test);
  void removeTest(String id);
  void removeAllTests();

  Future<List<TestResult>> sendUrlForScan({
    required String url,
    required List<String> tests,
  });
}
