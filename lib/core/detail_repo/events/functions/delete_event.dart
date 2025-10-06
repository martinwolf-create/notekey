import 'package:notekey_app/core/detail_repo/events/domain/event_repository.dart';

class DeleteEvent {
  final EventRepository repo;
  DeleteEvent(this.repo);

  Future<void> call(String id) => repo.delete(id);
}
