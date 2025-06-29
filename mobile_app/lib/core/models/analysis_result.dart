import 'package:json_annotation/json_annotation.dart';

part 'analysis_result.g.dart';

@JsonSerializable()
class AnalysisResult {
  final String id;
  final DateTime timestamp;
  final String imageUrl;
  final HerbClassificationResult herbClassification;
  final QualityAssessmentResult qualityAssessment;
  final DiseaseDetectionResult diseaseDetection;
  final MaturityAssessmentResult maturityAssessment;
  final GacpComplianceResult gacpCompliance;
  final List<String> recommendations;
  final int processingTimeMs;

  const AnalysisResult({
    required this.id,
    required this.timestamp,
    required this.imageUrl,
    required this.herbClassification,
    required this.qualityAssessment,
    required this.diseaseDetection,
    required this.maturityAssessment,
    required this.gacpCompliance,
    required this.recommendations,
    required this.processingTimeMs,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  AnalysisResult copyWith({
    String? id,
    DateTime? timestamp,
    String? imageUrl,
    HerbClassificationResult? herbClassification,
    QualityAssessmentResult? qualityAssessment,
    DiseaseDetectionResult? diseaseDetection,
    MaturityAssessmentResult? maturityAssessment,
    GacpComplianceResult? gacpCompliance,
    List<String>? recommendations,
    int? processingTimeMs,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      herbClassification: herbClassification ?? this.herbClassification,
      qualityAssessment: qualityAssessment ?? this.qualityAssessment,
      diseaseDetection: diseaseDetection ?? this.diseaseDetection,
      maturityAssessment: maturityAssessment ?? this.maturityAssessment,
      gacpCompliance: gacpCompliance ?? this.gacpCompliance,
      recommendations: recommendations ?? this.recommendations,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class HerbClassificationResult {
  final String predictedHerb;
  final double confidence;
  final Map<String, double> allProbabilities;
  final int inferenceTimeMs;

  const HerbClassificationResult({
    required this.predictedHerb,
    required this.confidence,
    required this.allProbabilities,
    required this.inferenceTimeMs,
  });

  factory HerbClassificationResult.fromJson(Map<String, dynamic> json) =>
      _$HerbClassificationResultFromJson(json);

  Map<String, dynamic> toJson() => _$HerbClassificationResultToJson(this);
}

@JsonSerializable()
class QualityAssessmentResult {
  final double overallScore;
  final double contaminationLevel;
  final double freshnessScore;
  final String qualityGrade;
  final bool gacpCompliant;
  final int inferenceTimeMs;

  const QualityAssessmentResult({
    required this.overallScore,
    required this.contaminationLevel,
    required this.freshnessScore,
    required this.qualityGrade,
    required this.gacpCompliant,
    required this.inferenceTimeMs,
  });

  factory QualityAssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$QualityAssessmentResultFromJson(json);

  Map<String, dynamic> toJson() => _$QualityAssessmentResultToJson(this);
}

@JsonSerializable()
class DiseaseDetectionResult {
  final List<DetectedIssue> detectedIssues;
  final double safetyScore;
  final String healthStatus;
  final int inferenceTimeMs;

  const DiseaseDetectionResult({
    required this.detectedIssues,
    required this.safetyScore,
    required this.healthStatus,
    required this.inferenceTimeMs,
  });

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseDetectionResultToJson(this);
}

@JsonSerializable()
class DetectedIssue {
  final String disease;
  final double confidence;
  final String severity;
  final String recommendation;

  const DetectedIssue({
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.recommendation,
  });

  factory DetectedIssue.fromJson(Map<String, dynamic> json) =>
      _$DetectedIssueFromJson(json);

  Map<String, dynamic> toJson() => _$DetectedIssueToJson(this);
}

@JsonSerializable()
class MaturityAssessmentResult {
  final double maturityScore;
  final double harvestReadiness;
  final String maturityStage;
  final bool optimalHarvest;
  final int daysToOptimal;
  final int inferenceTimeMs;

  const MaturityAssessmentResult({
    required this.maturityScore,
    required this.harvestReadiness,
    required this.maturityStage,
    required this.optimalHarvest,
    required this.daysToOptimal,
    required this.inferenceTimeMs,
  });

  factory MaturityAssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$MaturityAssessmentResultFromJson(json);

  Map<String, dynamic> toJson() => _$MaturityAssessmentResultToJson(this);
}

@JsonSerializable()
class GacpComplianceResult {
  final double score;
  final String status;
  final List<String> issues;
  final bool certificateReady;

  const GacpComplianceResult({
    required this.score,
    required this.status,
    required this.issues,
    required this.certificateReady,
  });

  factory GacpComplianceResult.fromJson(Map<String, dynamic> json) =>
      _$GacpComplianceResultFromJson(json);

  Map<String, dynamic> toJson() => _$GacpComplianceResultToJson(this);
}