enum ForumItemType { event, market }

class ForumItem {
  final int? id;
  final ForumItemType type;
  final String title; // kurzer Titel
  final String info; // Beschreibung
  final String? imagePath; // Dateipfad
  final DateTime? date; // nur für Veranstaltungen
  final int? priceCents;
  final String? currency; // nur für Such & Find

  ForumItem({
    this.id,
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
      type: type ?? this.type,
      title: title ?? this.title,
      info: info ?? this.info,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'title': title,
        'info': info,
        'image_path': imagePath,
        'date_epoch': date?.millisecondsSinceEpoch,
        'price_cents': priceCents,
        'price_currency': currency,
      };

  static ForumItem fromMap(Map<String, dynamic> m) => ForumItem(
        id: m['id'] as int?,
        type: ForumItemType.values[m['type'] as int],
        title: m['title'] as String,
        info: m['info'] as String,
        imagePath: m['image_path'] as String?,
        date: (m['date_epoch'] as int?) != null
            ? DateTime.fromMillisecondsSinceEpoch(m['date_epoch'] as int)
            : null,
        priceCents: m['price_cents'] as int?,
        currency: m['price_currency'] as String?,
      );
}
