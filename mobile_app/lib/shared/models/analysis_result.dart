import 'package:json_annotation/json_annotation.dart';

part 'analysis_result.g.dart';

@JsonSerializable(explicitToJson: true)
class AnalysisResult {
  final String id;
  final String herbName;
  final double confidence;
  final String imageUrl;
  final DateTime analyzedAt;
  final String? disease;
  final double? qualityScore;
  final String? recommendation;
  final Map<String, double>? allProbabilities;

  AnalysisResult({
    required this.id,
    required this.herbName,
    required this.confidence,
    required this.imageUrl,
    required this.analyzedAt,
    this.disease,
    this.qualityScore,
    this.recommendation,
    this.allProbabilities,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);
}