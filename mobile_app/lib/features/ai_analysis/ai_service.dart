// lib/core/services/ai_service.dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';
import '../../core/utils/logger.dart';

/// Production-ready AIService for TFLite model inference
class AIService {
  static Interpreter? _herbClassifier;
  static Interpreter? _qualityDetector;
  static Interpreter? _diseaseDetector;

  static const String herbModelPath = 'assets/ai_models/herb_classifier_mobile.tflite';
  static const String qualityModelPath = 'assets/ai_models/quality_detector_mobile.tflite';
  static const String diseaseModelPath = 'assets/ai_models/disease_detector_mobile.tflite';

  static bool get isReady =>
      _herbClassifier != null && _qualityDetector != null && _diseaseDetector != null;

  /// Initialize all AI models (call once at app start)
  static Future<void> initialize() async {
    try {
      _herbClassifier = await Interpreter.fromAsset(herbModelPath);
      _qualityDetector = await Interpreter.fromAsset(qualityModelPath);
      _diseaseDetector = await Interpreter.fromAsset(diseaseModelPath);
      AppLogger.info('AI Models loaded successfully');
    } catch (e, s) {
      AppLogger.error('Error loading AI models', e, s);
      rethrow;
    }
  }

  /// Analyze image and return structured result
  static Future<HerbAnalysisResult> analyzeImage(File imageFile) async {
    if (!isReady) await initialize();

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('ไม่สามารถอ่านไฟล์ภาพได้');
    }
    final resized = img.copyResize(image, width: 224, height: 224);
    final input = _imageToByteListFloat32(resized);

    // Run herb classification
    final herbOutput = List.filled(6, 0.0).reshape([1, 6]);
    _herbClassifier!.run(input, herbOutput);

    // Run quality detection
    final qualityOutput = List.filled(3, 0.0).reshape([1, 3]);
    _qualityDetector!.run(input, qualityOutput);

    // Run disease detection
    final diseaseOutput = List.filled(10, 0.0).reshape([1, 10]);
    _diseaseDetector!.run(input, diseaseOutput);

    return HerbAnalysisResult.fromModelOutputs(
      herbOutput[0],
      qualityOutput[0],
      diseaseOutput[0],
    );
  }

  /// Convert image to Float32 input for TFLite
  static Uint8List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(1 * 224 * 224 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        final pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - 127.5) / 127.5;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 127.5) / 127.5;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 127.5) / 127.5;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /// Dispose all interpreters (call on app shutdown)
  static void dispose() {
    _herbClassifier?.close();
    _qualityDetector?.close();
    _diseaseDetector?.close();
    _herbClassifier = null;
    _qualityDetector = null;
    _diseaseDetector = null;
    AppLogger.info('AI Models disposed');
  }
}

/// Structured result for herb analysis
class HerbAnalysisResult {
  final String herbName;
  final double confidence;
  final String qualityStatus;
  final List<String> detectedDiseases;
  final List<String> recommendations;

  HerbAnalysisResult({
    required this.herbName,
    required this.confidence,
    required this.qualityStatus,
    required this.detectedDiseases,
    required this.recommendations,
  });

  factory HerbAnalysisResult.fromModelOutputs(
    List<double> herbOutput,
    List<double> qualityOutput,
    List<double> diseaseOutput,
  ) {
    final herbLabels = ['กัญชา', 'ขมิ้นชัน', 'ขิง', 'กระชายดำ', 'ไพล', 'กระท่อม'];
    final maxHerbIndex = herbOutput.indexOf(herbOutput.reduce((a, b) => a > b ? a : b));

    return HerbAnalysisResult(
      herbName: herbLabels[maxHerbIndex],
      confidence: herbOutput[maxHerbIndex] * 100,
      qualityStatus: qualityOutput[0] > 0.7 ? 'ผ่านมาตรฐาน' : 'ต้องปรับปรุง',
      detectedDiseases: _processDiseaseOutput(diseaseOutput),
      recommendations: _generateRecommendations(qualityOutput, diseaseOutput),
    );
  }

  static List<String> _processDiseaseOutput(List<double> diseaseOutput) {
    final diseases = ['เชื้อรา', 'แบคทีเรีย', 'ไวรัส', 'แมลง', 'ความชื้นสูง'];
    final List<String> detected = [];
    for (int i = 0; i < diseaseOutput.length && i < diseases.length; i++) {
      if (diseaseOutput[i] > 0.5) {
        detected.add(diseases[i]);
      }
    }
    return detected;
  }

  static List<String> _generateRecommendations(
    List<double> qualityOutput,
    List<double> diseaseOutput,
  ) {
    final List<String> recommendations = [];
    if (qualityOutput[0] > 0.8) {
      recommendations.add('คุณภาพดีเยี่ยม พร้อมสำหรับการรับรอง');
    } else if (qualityOutput[0] > 0.6) {
      recommendations.add('คุณภาพปานกลาง ควรปรับปรุงการเก็บรักษา');
    } else {
      recommendations.add('คุณภาพต่ำ ต้องแก้ไขก่อนส่งรับรอง');
    }
    // สามารถเพิ่ม logic แนะนำจาก diseaseOutput ได้
    return recommendations;
  }
}