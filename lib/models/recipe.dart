class Recipe {
  final int id;
  final String name;
  final String cuisine;
  final String difficulty;
  final String image;

  Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.difficulty,
    required this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      cuisine: json['cuisine'],
      difficulty: json['difficulty'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'image': image,
    };
  }

  Recipe copyWith({
    int? id,
    String? name,
    String? cuisine,
    String? difficulty,
    String? image,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      image: image ?? this.image,
    );
  }
}