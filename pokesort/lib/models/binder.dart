class Binder {
  final int? id;
  final String name;
  final String? coverImage;
  final int pageCount;

  Binder({
    this.id,
    required this.name,
    this.coverImage,
    required this.pageCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
      'pageCount': pageCount,
    };
  }

  factory Binder.fromMap(Map<String, dynamic> map) {
    return Binder(
      id: map['id'] as int?,
      name: map['name'] as String,
      coverImage: map['coverImage'] as String?,
      pageCount: map['pageCount'] as int,
    );
  }
}
