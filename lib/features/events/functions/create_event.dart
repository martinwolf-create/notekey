import 'package:notekey_app/features/events/domain/event.dart';
import 'package:notekey_app/features/events/domain/event_repository.dart';

class CreateEvent {
  final EventRepository repo;
  CreateEvent(this.repo);

  Future<void> call({
    required String id,
    required String title,
    required DateTime date,
    String? location,
    String? description,
  }) =>
      repo.create(Event(
        id: id,
        title: title,
        date: date,
        location: location,
        description: description,
      ));
}
