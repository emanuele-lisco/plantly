import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final String id;
  final String name;
  final String species;
  final String room;
  final int moisture;
  final int light;
  final int health;
  final String nextAction;
  final String imageEmoji;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.room,
    required this.moisture,
    required this.light,
    required this.health,
    required this.nextAction,
    required this.imageEmoji,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        room,
        moisture,
        light,
        health,
        nextAction,
        imageEmoji,
      ];

  
}
