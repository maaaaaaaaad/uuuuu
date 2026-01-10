import 'package:flutter_test/flutter_test.dart';
import 'package:jellomark/core/usecase/usecase.dart';

class TestUseCase extends UseCase<String, TestParams> {
  @override
  Future<String> call(TestParams params) async {
    return params.value;
  }
}

class TestParams {
  final String value;

  TestParams(this.value);
}

void main() {
  group('UseCase', () {
    late TestUseCase useCase;

    setUp(() {
      useCase = TestUseCase();
    });

    test('should return result when called with params', () async {
      final result = await useCase(TestParams('test'));
      expect(result, 'test');
    });
  });

  group('NoParams', () {
    test('should be instantiable', () {
      final noParams = NoParams();
      expect(noParams, isA<NoParams>());
    });
  });
}
