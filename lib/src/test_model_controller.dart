import 'dart:async';
import 'package:flutter_mvu/flutter_mvu.dart';

/// A helper that wraps ModelController and exposes a
/// `dispatch()` method returning a Future that completes
/// after the event has been applied and the state stream
/// has emitted the new model.
class TestModelController<T extends Object> extends ModelController<T> {
  /// If true (the default), the controller is automatically
  /// disposed after each dispatch or batchDispatch.
  bool autoDispose;

  List<Event> _triggeredEvents = [];
  List<OutEvent> _emittedOutEvents = [];

  /// All events that have been passed into [triggerEvent].
  List<Event> get triggeredEvents => _triggeredEvents;

  /// All [OutEvent]s that have been emitted by [outEventStream].
  ///
  /// Captured so tests can assert on side-effects emitted
  /// by the controller.
  List<OutEvent> get emittedOutEvents => _emittedOutEvents;

  @override
  void triggerEvent(Event<T> event) {
    _triggeredEvents.add(event);
    super.triggerEvent(event);
  }

  /// Creates a [TestModelController] with the given [initialModel].
  ///
  /// [autoDispose] controls whether the controller should
  /// automatically call [dispose] after dispatching events.
  /// Defaults to true.
  TestModelController(super.initialModel, {this.autoDispose = true}) {
    outEventStream.listen((outEvent) => _emittedOutEvents.add(outEvent));
  }

  /// Dispatch an [event] and return a Future that completes
  /// when the [stream] emits the updated state.
  Future<void> dispatch(Event<T> event, {int returnAfterEvents = 1}) async {
    batchDispatch([event], returnAfterEvents: returnAfterEvents);
  }

  /// Triggers [events] in order, awaits the next
  /// [returnAfterEvents] state emissions, then (optionally)
  /// disposes this controller.
  Future<void> batchDispatch(List<Event<T>> events,
      {int? returnAfterEvents}) async {
    // We only want to collect exactly as many emissions as there are events.
    final sub = stream.take(returnAfterEvents ?? events.length).listen((_) {});
    for (final e in events) {
      triggerEvent(e);
    }
    await sub.asFuture<void>();
    await sub.cancel();
    if (autoDispose) super.dispose();
  }
}
