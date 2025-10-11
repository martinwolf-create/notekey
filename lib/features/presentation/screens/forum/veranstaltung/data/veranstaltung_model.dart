import 'package:cloud_firestore/cloud_firestore.dart';

class Veranstaltung {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? imageUrl;
  final String? location;

  Veranstaltung({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.imageUrl,
    this.location,
  });

  factory Veranstaltung.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Veranstaltung(
      id: doc.id,
      title: (d['title'] as String?)?.trim() ?? '',
      description: (d['description'] as String?)?.trim(),
      imageUrl: d['imageUrl'] as String?,
      location: (d['location'] as String?)?.trim(),
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
        'date': Timestamp.fromDate(date),
      };

  Veranstaltung copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? imageUrl,
    String? location,
  }) {
    return Veranstaltung(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
    );
  }
}
