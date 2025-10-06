import 'package:notekey_app/core/detail_repo/calendar/domain/calendar_entry.dart';
import 'package:notekey_app/core/detail_repo/calendar/data/calendar_repository.dart';

class ListMonthEntries {
  final CalendarRepository repo;
  ListMonthEntries(this.repo);

  Future<List<CalendarEntry>> call(DateTime month) => repo.listForMonth(month);
}
