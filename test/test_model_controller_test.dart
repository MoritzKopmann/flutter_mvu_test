import 'package:flutter_mvu/flutter_mvu.dart';
import 'package:flutter_mvu_test/flutter_mvu_test.dart';
import 'package:flutter_test/flutter_test.dart';

class Counter {
  int count = 0;
}

class IncrementEvent implements Event<Counter> {
  @override
  void updateModel(Counter model, _, __) => model.count++;
}

void main() {
  test('increment count via event', () async {
    //arrange
    final testController = TestModelController(Counter());
    expect(testController.model.count, 0);

    //act
    await testController.dispatch(IncrementEvent());

    //assert
    expect(testController.model.count, 1);
    expect(testController.emittedOutEvents, isEmpty);
  });

  test('increment sequence', () async {
    //arrange
    final testController = TestModelController(Counter());
    // sequence of two increments

    //act
    await testController.batchDispatch([
      IncrementEvent(),
      IncrementEvent(),
    ]);

    //assert
    expect(testController.model.count, 2);
    expect(testController.emittedOutEvents, isEmpty);
  });
}
