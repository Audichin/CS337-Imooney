class Binder {
  final int? id;
  final String name;
  final String? coverImage;

  Binder({
    this.id,
    required this.name,
    this.coverImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
    };
  }

  factory Binder.fromMap(Map<String, dynamic> map) {
    return Binder(
      id: map['id'],
      name: map['name'],
      coverImage: map['coverImage'],
    );
  }
}