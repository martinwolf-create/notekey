// Trennt die Bereiche
enum MarketKind { such, find }

// Datenmodell für Collection "suchfind"
class Suchfind {
  final String? id; // Firestore Doc-ID
  final String title;
  final String? description; // -> Firestore-Feld "info"
  final String? imageUrl; // HTTP-URL (Firebase Storage)
  final DateTime? createdAt;

  const Suchfind({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  Suchfind copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Suchfind(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
