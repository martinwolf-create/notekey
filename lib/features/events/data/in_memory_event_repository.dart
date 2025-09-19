import 'package:notekey_app/features/events/domain/event.dart';
import 'package:notekey_app/features/events/domain/event_repository.dart';

class InMemoryEventRepository implements EventRepository {
  final List<Event> _events = [];

  @override
  Future<void> create(Event event) async {
    if (_events.any((e) => e.id == event.id)) return;
    _events.add(event);
    _events.sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<Event>> listForMonth(DateTime inMonth) async {
    final start = DateTime(inMonth.year, inMonth.month, 1);
    final end = DateTime(inMonth.year, inMonth.month + 1, 1);
    final filtered = _events
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(filtered);
  }

  @override
  Future<void> update(Event event) async {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i != -1) _events[i] = event;
  }

  @override
  Future<void> delete(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
  }
}
