import 'package:notekey_app/features/ungenutzt/events/domain/event.dart';

abstract class EventRepository {
  Future<void> create(Event event);
  Future<List<Event>> listForMonth(DateTime inMonth);
  Future<void> update(Event event);
  Future<void> delete(String eventId);
}
