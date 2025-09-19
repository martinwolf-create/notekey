import 'package:notekey_app/features/calendar/domain/calendar_entry.dart';

abstract class CalendarRepository {
  Future<void> add(CalendarEntry entry);
  Future<List<CalendarEntry>> listForMonth(DateTime inMonth);
  Future<void> remove(String entryId);
}
