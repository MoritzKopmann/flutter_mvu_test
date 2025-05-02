# flutter_mvu_test 🧪


Official test utilities for **flutter_mvu** [![flutter_mvu pub version](https://img.shields.io/pub/v/flutter_mvu.svg)](https://pub.dev/packages/flutter_mvu). Simplify your unit and widget testing with `TestModelController`, which lets you dispatch events synchronously and assert on state and out-events.

---

## 📦 Installation

Add **flutter_mvu_test** to your `dev_dependencies` in the parent package's `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_mvu_test: ^0.1.0
```

Then fetch packages:

```bash
flutter pub get
```

Import in your test files:

```dart
import 'package:flutter_mvu_test/flutter_mvu_test.dart';
import 'package:flutter_mvu/flutter_mvu.dart';
```

---

## 🛠️ Core Utility: `TestModelController<T>`

Wraps `ModelController<T>` to provide:

- **`dispatch(Event<T> event)`**: Triggers an event and awaits the next state emission.
- **`batchDispatch(List<Event<T>> events)`**: Fire multiple events, await a specified number of state updates.
- **`triggeredEvents`**: A list of all events passed to the controller (in dispatch or direct trigger).
- **`emittedOutEvents`**: Captures all `OutEvent<T>` instances emitted by the model.
- **`autoDispose`**: Automatically disposes the controller after dispatch by default (toggle via constructor).

### API Reference

```dart
class TestModelController<T extends Object> extends ModelController<T> {
  /// If true, calls dispose() after every dispatch batch (default: true).
  final bool autoDispose;

  /// List of all events that have been triggered.
  List<Event> get triggeredEvents;

  /// List of all OutEvent<T> emitted during dispatch.
  List<OutEvent> get emittedOutEvents;

  /// Constructs a TestModelController with an initial model.
  TestModelController(
    T initialModel, {
    this.autoDispose = true,
  });

  /// Dispatch a single event and await the state update(s).
  Future<void> dispatch(
    Event<T> event, {
    int returnAfterEvents = 1,
  });

  /// Dispatch multiple events in sequence and await [returnAfterEvents] updates.
  Future<void> batchDispatch(
    List<Event<T>> events, {
    int? returnAfterEvents,
  });
}
```

---

## 🚀 Usage Examples

### 1️⃣ Single Event Dispatch

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mvu/flutter_mvu.dart';
import 'package:flutter_mvu_test/flutter_mvu_test.dart';

class CounterModel { int count = 0; }
class IncrementEvent implements Event<CounterModel> {
  @override
  void updateModel(CounterModel model, _, __) {
    model.count++;
  }
}

test('dispatch single event updates state', () async {
  final controller = TestModelController(CounterModel());

  // Before dispatch
  expect(controller.model.count, 0);

  // Dispatch and await one state update
  await controller.dispatch(IncrementEvent());

  // After dispatch
  expect(controller.model.count, 1);
  expect(controller.triggeredEvents, isA<List<Event>>());
});
```

### 2️⃣ Batch Event Dispatch

```dart
test('batch dispatch applies events in order', () async {
  final controller = TestModelController(CounterModel(), autoDispose: false);

  // Fire two increments and await two updates
  await controller.batchDispatch(
    [IncrementEvent(), IncrementEvent()],
    returnAfterEvents: 2,
  );

  expect(controller.model.count, 2);
  expect(controller.triggeredEvents.length, 2);
});
```

### 3️⃣ OutEvent Assertion

```dart
class ChildModel { /*…*/ }
class ChildDidSomething extends OutEvent<ChildModel> {
  final String message;
  ChildDidSomething(this.message);
}

class EmitOutEvent implements Event<ChildModel> {
  @override
  void updateModel(ChildModel model, _, triggerOut) {
    triggerOut(ChildDidSomething('test'));
  }
}

test('captures OutEvent emissions', () async {
  final controller = TestModelController(ChildModel());

  await controller.dispatch(EmitOutEvent());

  expect(controller.emittedOutEvents, contains(isA<ChildDidSomething>()));
});
```

---

## 📚 Notes

- **Disposal**: By default, `autoDispose` cleans up internal streams after each dispatch batch. Set `autoDispose: false` to retain the controller across multiple tests, but remember to call `dispose()` manually.
- **Asynchronous Boundaries**: `dispatch` awaits the next state snapshot; if your model emits additional states (e.g., dummy loading states), adjust `returnAfterEvents` accordingly.

---

Crafted with ❤️ for the **flutter_mvu** ecosystem.

