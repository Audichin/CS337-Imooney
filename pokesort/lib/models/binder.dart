class Binder {
  final int? id;
  final String name;
  final String? coverImage;
  final int sheetCount;

  Binder({
    this.id,
    required this.name,
    this.coverImage,
    required this.sheetCount,
  });

  int get virtualPageCount => sheetCount * 2;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
      'sheetCount': sheetCount,
    };
  }

  factory Binder.fromMap(Map<String, dynamic> map) {
    return Binder(
      id: map['id'] as int?,
      name: map['name'] as String,
      coverImage: map['coverImage'] as String?,
      sheetCount: map['sheetCount'] as int,
    );
  }
}