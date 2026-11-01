import 'sos_event.dart';

abstract class SosRepository {
  Stream<List<SosEvent>> watchAll();
  Stream<List<SosEvent>> watchActive();
  Stream<SosEvent?> watch(String id);
  Future<SosEvent?> get(String id);

  /// Active events, newest first.
  Future<List<SosEvent>> active();

  /// Inserts the event and enqueues it for cloud sync. Duplicate ids are ignored.
  Future<bool> create(SosEvent event);

  /// Moves an event to [status]. Transitions that would move an event
  /// backwards (e.g. propagated -> acknowledged) or out of a closed state are
  /// ignored, so late or duplicate acknowledgements are harmless.
  Future<void> advance(
    String id,
    SosStatus status, {
    int? nodesReached,
    bool simulated = false,
    DateTime? at,
  });
}
