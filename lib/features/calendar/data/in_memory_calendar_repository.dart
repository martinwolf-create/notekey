import 'package:notekey_app/features/calendar/domain/calendar_entry.dart';
import 'package:notekey_app/features/calendar/data/calendar_repository.dart';

class InMemoryCalendarRepository implements CalendarRepository {
  final List<CalendarEntry> _entries = [];

  @override
  Future<void> add(CalendarEntry entry) async {
    if (_entries.any((e) => e.id == entry.id)) return;
    _entries.add(entry);
    _entries.sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<CalendarEntry>> listForMonth(DateTime inMonth) async {
    final start = DateTime(inMonth.year, inMonth.month, 1);
    final end = DateTime(inMonth.year, inMonth.month + 1, 1);
    final filtered = _entries
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(filtered);
  }

  @override
  Future<void> remove(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
  }
}
