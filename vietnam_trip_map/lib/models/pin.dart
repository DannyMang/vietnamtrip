class Pin {
  final String? id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final PinType type;
  final DateTime? createdAt;

  Pin({
    this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.createdAt,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      type: PinType.fromString(json['type']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.value,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

enum PinType {
  shopping('shopping'),
  activity('activity'),
  food('food'),
  beauty('beauty'),
  hotel('hotel');

  final String value;
  const PinType(this.value);

  static PinType fromString(String value) {
    return PinType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PinType.activity,
    );
  }

  String get emoji {
    switch (this) {
      case PinType.shopping:
        return '🛍️';
      case PinType.activity:
        return '🎨';
      case PinType.food:
        return '🍴';
      case PinType.beauty:
        return '💅';
      case PinType.hotel:
        return '🏨';
    }
  }
}
