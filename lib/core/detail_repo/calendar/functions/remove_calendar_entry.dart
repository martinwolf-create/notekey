import 'package:notekey_app/core/detail_repo/calendar/data/calendar_repository.dart';

class RemoveCalendarEntry {
  final CalendarRepository repo;
  RemoveCalendarEntry(this.repo);

  Future<void> call(String id) => repo.remove(id);
}
