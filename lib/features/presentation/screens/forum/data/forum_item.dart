enum ForumItemType { event, market }

class ForumItem {
  final int? id; // lokal (SQLite)
  final String? fsId; // Firestore-Dokument-ID
  final String? ownerUid; // Ersteller-UID

  final ForumItemType type;
  final String title;
  final String info;
  final String? imagePath; // Pfad oder URL
  final DateTime? date;
  final int? priceCents;
  final String? currency;

  const ForumItem({
    this.id,
    this.fsId,
    this.ownerUid,
    required this.type,
    required this.title,
    required this.info,
    this.imagePath,
    this.date,
    this.priceCents,
    this.currency,
  });

  ForumItem copyWith({
    int? id,
    String? fsId,
    String? ownerUid,
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
      ownerUid: ownerUid ?? this.ownerUid,
      type: type ?? this.type,
      title: title ?? this.title,
      info: info ?? this.info,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
    );
  }

  // SQLite: Map zu Item (legacy kompatibel)
  factory ForumItem.fromSqlMap(Map<String, dynamic> m) {
    return ForumItem(
      id: m['id'] as int?,
      fsId: null,
      ownerUid: null,
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

  // SQLite: Item zu Map
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

  // Firestore: Map (+ fsId) zu Item
  factory ForumItem.fromFirestore(
    Map<String, dynamic> m, {
    required String fsId,
  }) {
    final imageUrl = (m['imageUrl'] as String?)?.trim();
    final imagePathLegacy = (m['image_path'] as String?)?.trim();

    return ForumItem(
      id: null,
      fsId: fsId,
      ownerUid:
          (m['uid'] as String?)?.trim() ?? (m['ownerUid'] as String?)?.trim(),
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

  // Firestore: Item -> Map
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
