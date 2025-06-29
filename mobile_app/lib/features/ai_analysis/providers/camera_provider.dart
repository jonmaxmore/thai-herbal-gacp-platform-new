import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../../core/utils/logger.dart';

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(const CameraState());

  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('ไม่พบกล้องในอุปกรณ์');
      }

      await _initializeController();
      
    } catch (e) {
      AppLogger.error('Camera initialization failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _initializeController() async {
    if (_cameras.isEmpty) return;

    final camera = _cameras[_currentCameraIndex];
    final controller = CameraController(
      camera,
      state.isHighResolution ? ResolutionPreset.high : ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      
      state = state.copyWith(
        controller: controller,
        isLoading: false,
        isInitialized: true,
        error: null,
      );

      AppLogger.info('Camera initialized successfully');
      
    } catch (e) {
      controller.dispose();
      throw Exception('ไม่สามารถเริ่มต้นกล้องได้: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;

    state = state.copyWith(isLoading: true);

    try {
      await state.controller?.dispose();
      
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _initializeController();
      
    } catch (e) {
      AppLogger.error('Failed to switch camera', e);
      state = state.copyWith(
        isLoading: false,
        error: 'ไม่สามารถเปลี่ยนกล้องได้',
      );
    }
  }

  Future<void> toggleFlash() async {
    if (!state.isInitialized) return;

    try {
      final newFlashMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
      await state.controller!.setFlashMode(newFlashMode);
      
      state = state.copyWith(isFlashOn: !state.isFlashOn);
      
    } catch (e) {
      AppLogger.error('Failed to toggle flash', e);
    }
  }

  void setResolution(bool highResolution) {
    if (state.isHighResolution == highResolution) return;
    
    state = state.copyWith(isHighResolution: highResolution);
    
    // Reinitialize camera with new resolution
    if (state.isInitialized) {
      _reinitializeCamera();
    }
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  Future<void> _reinitializeCamera() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await state.controller?.dispose();
      await _initializeController();
    } catch (e) {
      AppLogger.error('Failed to reinitialize camera', e);
      state = state.copyWith(
        isLoading: false,
        error: 'ไม่สามารถเริ่มต้นกล้องใหม่ได้',
      );
    }
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final bool isFlashOn;
  final bool isHighResolution;
  final bool showGrid;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.isFlashOn = false,
    this.isHighResolution = true,
    this.showGrid = false,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool? isFlashOn,
    bool? isHighResolution,
    bool? showGrid,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isHighResolution: isHighResolution ?? this.isHighResolution,
      showGrid: showGrid ?? this.showGrid,
    );
  }
}