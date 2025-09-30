enum ForumItemType { event, market }

class ForumItem {
  /// Lokale SQLite-ID (optional)
  final int? id;

  /// Firestore-Dokument-ID (optional)
  final String? fsId;

  final ForumItemType type;
  final String title; // kurzer Titel
  final String info; // Beschreibung
  final String? imagePath; // Dateipfad oder URL
  final DateTime? date; // nur für Veranstaltungen
  final int? priceCents;
  final String? currency; // z. B. "EUR" (nur für Such & Find)

  const ForumItem({
    this.id,
    this.fsId,
    required this.type,
    required this.title,
    required this.info,
    this.imagePath,
    this.date,
    this.priceCents,
    this.currency,
  });

  /// Kopie mit überschriebenen Feldern
  ForumItem copyWith({
    int? id,
    String? fsId,
    ForumItemType? type,
    String? title,
    String? info,
    String? imagePath,
    DateTime? date,
    int? priceCents,
    String? currency,
  }) {
    return ForumItem(
      id: id ?? this.id,
      fsId: fsId ?? this.fsId,
      type: type ?? this.type,
      title: title ?? this.title,
      info: info ?? this.info,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
    );
  }

  /// ---- SQLite-Mapping ----

  /// Für `sqflite`: Map -> ForumItem
  factory ForumItem.fromSqlMap(Map<String, dynamic> m) {
    return ForumItem(
      id: m['id'] as int?,
      fsId: null, // SQLite kennt keine Firestore-ID
      type: ForumItemType.values[m['type'] as int],
      title: m['title'] as String,
      info: m['info'] as String,
      imagePath: (m['imageUrl'] ?? m['image_path']) as String?,

      date: (m['date_epoch'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(m['date_epoch'] as int)
          : null,
      priceCents: m['price_cents'] as int?,
      currency: m['price_currency'] as String?,
    );
  }

  /// Für `sqflite`: ForumItem -> Map
  Map<String, dynamic> toSqlMap() => {
        'id': id,
        'type': type.index,
        'title': title,
        'info': info,
        'image_path': imagePath,
        'date_epoch': date?.millisecondsSinceEpoch,
        'price_cents': priceCents,
        'price_currency': currency,
      };

  // Firestore: Map (+ fsId) -> ForumItem
  factory ForumItem.fromFirestore(
    Map<String, dynamic> m, {
    required String fsId,
  }) {
    final imageUrl = (m['imageUrl'] as String?)?.trim();
    final imagePathLegacy = (m['image_path'] as String?)?.trim();

    return ForumItem(
      id: null,
      fsId: fsId,
      type: ForumItemType.values[(m['type'] ?? 0) as int],
      title: (m['title'] ?? '') as String,
      info: (m['info'] ?? '') as String,
      imagePath: (imageUrl != null && imageUrl.isNotEmpty)
          ? imageUrl
          : imagePathLegacy,
      date: (m['date_epoch'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(m['date_epoch'] as int)
          : null,
      priceCents: m['price_cents'] as int?,
      currency: m['price_currency'] as String?,
    );
  }

  // Optional: ForumItem Firestore-Map
  Map<String, dynamic> toFirestoreMap() => {
        'type': type.index,
        'title': title,
        'info': info,
        'image_path': imagePath,
        'date_epoch': date?.millisecondsSinceEpoch,
        'price_cents': priceCents,
        'price_currency': currency,
      };
}
