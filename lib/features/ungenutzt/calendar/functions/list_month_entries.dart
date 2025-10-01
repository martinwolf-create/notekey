import 'package:notekey_app/features/ungenutzt/calendar/domain/calendar_entry.dart';
import 'package:notekey_app/features/ungenutzt/calendar/data/calendar_repository.dart';

class ListMonthEntries {
  final CalendarRepository repo;
  ListMonthEntries(this.repo);

  Future<List<CalendarEntry>> call(DateTime month) => repo.listForMonth(month);
}
