import 'package:notekey_app/features/calendar/domain/calendar_entry.dart';
import 'package:notekey_app/features/calendar/data/calendar_repository.dart';

class AddCalendarEntry {
  final CalendarRepository repo;
  AddCalendarEntry(this.repo);

  Future<void> call({
    required String id,
    required DateTime date,
    required String title,
    String? note,
  }) =>
      repo.add(CalendarEntry(id: id, date: date, title: title, note: note));
}
