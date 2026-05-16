class Plant {
  final String id;
  final String name;
  final String species;
  final int wateringFrequency;
  final DateTime lastWatered;
  final String? photoUrl;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.wateringFrequency,
    required this.lastWatered,
    this.photoUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Plant',
      species: json['species']?.toString() ?? '',
      wateringFrequency: (json['watering_frequency'] as num?)?.toInt() ?? 7,
      lastWatered: json['last_watered'] != null 
          ? DateTime.parse(json['last_watered']) 
          : DateTime.now(),
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'watering_frequency': wateringFrequency,
      'last_watered': lastWatered.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  Plant copyWith({
    String? name,
    String? species,
    int? wateringFrequency,
    DateTime? lastWatered,
    String? photoUrl,
  }) {
    return Plant(
      id: this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      lastWatered: lastWatered ?? this.lastWatered,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
