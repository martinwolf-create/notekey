import 'package:notekey_app/features/ungenutzt/events/domain/event.dart';
import 'package:notekey_app/features/ungenutzt/events/domain/event_repository.dart';

class ListEventsForMonth {
  final EventRepository repo;
  ListEventsForMonth(this.repo);

  Future<List<Event>> call(DateTime inMonth) => repo.listForMonth(inMonth);
}
