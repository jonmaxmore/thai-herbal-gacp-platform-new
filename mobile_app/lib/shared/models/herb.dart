import 'package:json_annotation/json_annotation.dart';

part 'herb.g.dart';

@JsonSerializable()
class Herb {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final List<String> uses;
  final List<String>? regions;
  final List<String>? diseasesResistant;

  Herb({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.uses,
    this.regions,
    this.diseasesResistant,
  });

  factory Herb.fromJson(Map<String, dynamic> json) => _$HerbFromJson(json);

  Map<String, dynamic> toJson() => _$HerbToJson(this);
}