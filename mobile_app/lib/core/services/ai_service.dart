import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onnxruntime/onnxruntime.dart';

/// Production-ready AIService for ONNX model inference
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  late final OrtEnvironment _env;
  OrtSession? _diseaseSession;
  OrtSession? _qualitySession;
  OrtSession? _herbSession;

  bool get isReady =>
      _diseaseSession != null && _qualitySession != null && _herbSession != null;

  Future<void> init() async {
    _env = OrtEnvironment();
    _diseaseSession = await _loadModel('assets/ai_models/models/disease_detector_v1.onnx');
    _qualitySession = await _loadModel('assets/ai_models/models/quality_detector_v1.onnx');
    _herbSession = await _loadModel('assets/ai_models/models/herb_classifier_v1.onnx');
  }

  Future<OrtSession> _loadModel(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${assetPath.split('/').last}');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return OrtSession.fromBuffer(_env, await file.readAsBytes());
    } catch (e, s) {
      // Logging for production
      print('AIService: Failed to load model $assetPath: $e\n$s');
      rethrow;
    }
  }

  Future<List<double>> runDiseaseModel(List<double> input, List<int> shape) async {
    if (_diseaseSession == null) throw Exception('Disease model not loaded');
    final inputTensor = OrtValue.tensorFromListFloat(input, shape);
    final outputs = _diseaseSession!.run({'input': inputTensor});
    return outputs.values.first.toListFloat();
  }

  Future<List<double>> runQualityModel(List<double> input, List<int> shape) async {
    if (_qualitySession == null) throw Exception('Quality model not loaded');
    final inputTensor = OrtValue.tensorFromListFloat(input, shape);
    final outputs = _qualitySession!.run({'input': inputTensor});
    return outputs.values.first.toListFloat();
  }

  Future<List<double>> runHerbModel(List<double> input, List<int> shape) async {
    if (_herbSession == null) throw Exception('Herb model not loaded');
    final inputTensor = OrtValue.tensorFromListFloat(input, shape);
    final outputs = _herbSession!.run({'input': inputTensor});
    return outputs.values.first.toListFloat();
  }

  void dispose() {
    _diseaseSession?.close();
    _qualitySession?.close();
    _herbSession?.close();
  }

  /// Reload all models (for hot reload or model update)
  Future<void> reloadModels() async {
    dispose();
    await init();
  }
}