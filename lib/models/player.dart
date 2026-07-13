enum Gender { male, female }

class Player {
  final String name;
  final Gender gender;

  const Player({required this.name, required this.gender});

  Player copyWith({String? name, Gender? gender}) {
    return Player(name: name ?? this.name, gender: gender ?? this.gender);
  }

  @override
  bool operator ==(Object other) =>
      other is Player && other.name == name && other.gender == gender;

  @override
  int get hashCode => Object.hash(name, gender);

  @override
  String toString() => name;
}
