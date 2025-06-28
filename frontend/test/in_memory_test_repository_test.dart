import 'package:flutter_test/flutter_test.dart';
import 'package:inno_test/data/repositories/in_memory_test_repository.dart';
import 'package:inno_test/domain/model/test.dart';

void main() {
  group('InMemoryTestRepository', () {
    late InMemoryTestRepository repo;

    setUp(() {
      repo = InMemoryTestRepository();
    });

    test('addTest and getTests works', () {
      final test = Test(id: '1', testName: 'Existence');
      repo.addTest(test);

      final allTests = repo.getTests();
      expect(allTests.length, 1);
      expect(allTests.first.testName, 'Existence');
    });

    test('removeTest removes by id', () {
      final test = Test(id: '5', testName: 'ToDelete');
      repo.addTest(test);

      repo.removeTest('5');
      expect(repo.getTests().length, 0);
    });

    test('removeAllTests clears list', () {
      repo.addTest(Test(id: '1', testName: 'T1'));
      repo.addTest(Test(id: '2', testName: 'T2'));

      repo.removeAllTests();
      expect(repo.getTests(), isEmpty);
    });
  });
}
