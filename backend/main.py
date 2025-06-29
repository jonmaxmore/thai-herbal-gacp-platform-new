"""
GACP Herbal AI Platform - Main FastAPI Application
Production-ready backend with comprehensive features
"""

import asyncio
import logging
import os
import sys
from contextlib import asynccontextmanager
from pathlib import Path

import uvicorn
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

# Import core modules
from app.core.config import settings
from app.core.database import engine, Base, get_db
from app.core.security import verify_api_key
from app.core.monitoring import MonitoringMiddleware, system_monitor
from app.core.exceptions import (
    CustomHTTPException,
    custom_http_exception_handler,
    validation_exception_handler,
    python_exception_handler
)

# Import services
from app.services.ai_service import AIService
from app.services.notification_service import NotificationService
from app.services.cache_service import CacheService

# Import API routers
from app.api.v1 import (
    auth,
    users,
    herbs,
    ai_analysis,
    certificates,
    tracking,
    admin,
    health
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/app.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Rate limiting
limiter = Limiter(key_func=get_remote_address)

# Application lifespan events
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events"""
    # Startup
    logger.info("🚀 Starting GACP Herbal AI Platform...")
    
    try:
        # Create database tables
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created")
        
        # Initialize services
        await AIService.initialize()
        logger.info("✅ AI Service initialized")
        
        await NotificationService.initialize()
        logger.info("✅ Notification Service initialized")
        
        await CacheService.initialize()
        logger.info("✅ Cache Service initialized")
        
        # Start system monitoring
        asyncio.create_task(system_monitor.start_monitoring())
        logger.info("✅ System monitoring started")
        
        logger.info("🎉 Application startup completed")
        
    except Exception as e:
        logger.error(f"❌ Application startup failed: {e}")
        raise e
    
    yield
    
    # Shutdown
    logger.info("🛑 Shutting down application...")
    
    try:
        system_monitor.stop_monitoring()
        AIService.cleanup()
        await CacheService.cleanup()
        logger.info("✅ Application shutdown completed")
        
    except Exception as e:
        logger.error(f"❌ Application shutdown error: {e}")

# Create FastAPI application
app = FastAPI(
    title="GACP Herbal AI Platform API",
    description="""
    ## GACP Herbal AI Platform - Production API
    
    Advanced AI-powered platform for Thai herbal plant GACP certification.
    
    ### Features
    - 🤖 AI-powered herb identification and quality assessment
    - 📱 Multi-platform support (Mobile, Desktop, Web)
    - 🔐 Secure authentication and authorization
    - 📊 Real-time analytics and monitoring
    - 🏥 GACP compliance verification
    - 📋 Certificate management system
    - 🔍 Complete track & trace functionality
    
    ### Authentication
    Most endpoints require Bearer token authentication.
    API key authentication is available for system integrations.
    
    ### Rate Limiting
    - Authenticated users: 1000 requests/hour
    - Anonymous users: 100 requests/hour
    - AI analysis: 50 requests/hour per user
    
    ### Support
    - Documentation: `/docs` (Swagger UI)
    - ReDoc: `/redoc`
    - Health Check: `/health`
    - Metrics: `/metrics` (Prometheus format)
    """,
    version="2.0.0",
    contact={
        "name": "Predictive AI Solution Co., Ltd.",
        "email": "support@predictive-ai.co.th",
        "url": "https://www.predictive-ai.co.th"
    },
    license_info={
        "name": "Proprietary License",
        "url": "https://www.predictive-ai.co.th/license"
    },
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
    openapi_url="/openapi.json" if settings.ENVIRONMENT != "production" else None,
    lifespan=lifespan,
)

# Security Middleware
if settings.ENVIRONMENT == "production":
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.ALLOWED_HOSTS
    )

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
    expose_headers=["X-Total-Count", "X-Rate-Limit-*"],
)

# Compression Middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Monitoring Middleware
app.add_middleware(MonitoringMiddleware)

# Rate Limiting Middleware
app.add_middleware(SlowAPIMiddleware)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Custom Exception Handlers
app.add_exception_handler(CustomHTTPException, custom_http_exception_handler)
app.add_exception_handler(422, validation_exception_handler)
app.add_exception_handler(Exception, python_exception_handler)

# Static files
static_path = Path("static")
static_path.mkdir(exist_ok=True)
app.mount("/static", StaticFiles(directory=static_path), name="static")

# API Routes
api_v1_prefix = "/api/v1"

app.include_router(
    health.router,
    prefix="/health",
    tags=["Health Check"]
)

app.include_router(
    auth.router,
    prefix=f"{api_v1_prefix}/auth",
    tags=["Authentication"]
)

app.include_router(
    users.router,
    prefix=f"{api_v1_prefix}/users",
    tags=["User Management"]
)

app.include_router(
    herbs.router,
    prefix=f"{api_v1_prefix}/herbs",
    tags=["Herb Database"]
)

app.include_router(
    ai_analysis.router,
    prefix=f"{api_v1_prefix}/analysis",
    tags=["AI Analysis"]
)

app.include_router(
    certificates.router,
    prefix=f"{api_v1_prefix}/certificates",
    tags=["GACP Certificates"]
)

app.include_router(      // Create dummy input (224x224x3 normalized image)
      final dummyInput = Float32List(1 * 224 * 224 * 3);
      for (int i = 0; i < dummyInput.length; i++) {
        dummyInput[i] = 0.0; // Normalized black image
      }
      
      final inputBuffer = dummyInput.buffer.asUint8List();
      
      // Warm up each model
      await Future.wait([
        _runHerbClassification(inputBuffer),
        _runQualityAssessment(inputBuffer),
        _runDiseaseDetection(inputBuffer),
        _runMaturityAssessment(inputBuffer),
      ]);
      
      AppLogger.debug('🔥 Models warmed up successfully');
      
    } catch (e) {
      AppLogger.warning('Model warm-up failed (non-critical)', e);
    }
  }

  Future<AnalysisResult> analyzeImage(File imageFile) async {
    if (!_isInitialized) {
      throw StateError('AI Service not initialized. Call initialize() first.');
    }

    try {
      AppLogger.info('🔍 Starting image analysis: ${imageFile.path}');
      final analysisStartTime = DateTime.now();

      // Preprocess image
      final preprocessedImage = await _preprocessImage(imageFile);
      
      // Run all AI models in parallel for faster processing
      final results = await Future.wait([
        _runHerbClassification(preprocessedImage),
        _runQualityAssessment(preprocessedImage),
        _runDiseaseDetection(preprocessedImage),
        _runMaturityAssessment(preprocessedImage),
      ]);

      final herbResult = results[0] as HerbClassificationResult;
      final qualityResult = results[1] as QualityAssessmentResult;
      final diseaseResult = results[2] as DiseaseDetectionResult;
      final maturityResult = results[3] as MaturityAssessmentResult;

      // Combine all results
      final analysisResult = AnalysisResult(
        id: _generateAnalysisId(),
        timestamp: DateTime.now(),
        imageUrl: imageFile.path,
        herbClassification: herbResult,
        qualityAssessment: qualityResult,
        diseaseDetection: diseaseResult,
        maturityAssessment: maturityResult,
        gacpCompliance: _evaluateGacpCompliance(
          herbResult,
          qualityResult,
          diseaseResult,
        ),
        recommendations: _generateRecommendations(
          herbResult,
          qualityResult,
          diseaseResult,
          maturityResult,
        ),
        processingTimeMs: DateTime.now().difference(analysisStartTime).inMilliseconds,
      );

      AppLogger.info(
        '✅ Analysis completed in ${analysisResult.processingTimeMs}ms: '
        '${herbResult.predictedHerb} (${herbResult.confidence.toStringAsFixed(1)}%)'
      );

      return analysisResult;

    } catch (e, stackTrace) {
      AppLogger.error('Image analysis failed', e, stackTrace);
      rethrow;
    }
  }

  Future<Uint8List> _preprocessImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw ArgumentError('Invalid image format');
      }

      // Resize to model input size (224x224)
      final resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to normalized Float32 array
      final input = Float32List(1 * 224 * 224 * 3);
      int pixelIndex = 0;

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          // Normalize to [-1, 1] range (as expected by MobileNet-based models)
          input[pixelIndex++] = (img.getRed(pixel) / 127.5) - 1.0;
          input[pixelIndex++] = (img.getGreen(pixel) / 127.5) - 1.0;
          input[pixelIndex++] = (img.getBlue(pixel) / 127.5) - 1.0;
        }
      }

      return input.buffer.asUint8List();

    } catch (e) {
      AppLogger.error('Image preprocessing failed', e);
      rethrow;
    }
  }

  Future<HerbClassificationResult> _runHerbClassification(Uint8List inputBuffer) async {
    if (_herbClassifier == null) {
      throw StateError('Herb classifier not loaded');
    }

    try {
      final input = [inputBuffer];
      final output = [Float32List(herbClasses.length)];
      
      final startTime = DateTime.now();
      _herbClassifier!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      final probabilities = output[0];
      final maxIndex = _argMax(probabilities);
      final confidence = probabilities[maxIndex] * 100;

      // Get all probabilities for detailed analysis
      final allProbabilities = <String, double>{};
      for (int i = 0; i < herbClasses.length; i++) {
        allProbabilities[herbClasses[i]] = probabilities[i] * 100;
      }

      return HerbClassificationResult(
        predictedHerb: herbClasses[maxIndex],
        confidence: confidence,
        allProbabilities: allProbabilities,
        inferenceTimeMs: inferenceTime,
      );

    } catch (e) {
      AppLogger.error('Herb classification failed', e);
      rethrow;
    }
  }

  Future<QualityAssessmentResult> _runQualityAssessment(Uint8List inputBuffer) async {
    if (_qualityDetector == null) {
      throw StateError('Quality detector not loaded');
    }

    try {
      final input = [inputBuffer];
      final output = [Float32List(3)]; // [overall_quality, contamination, freshness]
      
      final startTime = DateTime.now();
      _qualityDetector!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      final results = output[0];
      final overallQuality = results[0];
      final contaminationLevel = results[1];
      final freshnessScore = results[2];

      // Calculate quality grade
      final qualityGrade = _calculateQualityGrade(
        overallQuality,
        contaminationLevel,
        freshnessScore,
      );

      return QualityAssessmentResult(
        overallScore: overallQuality * 100,
        contaminationLevel: contaminationLevel * 100,
        freshnessScore: freshnessScore * 100,
        qualityGrade: qualityGrade,
        gacpCompliant: overallQuality > 0.8 && contaminationLevel < 0.2,
        inferenceTimeMs: inferenceTime,
      );

    } catch (e) {
      AppLogger.error('Quality assessment failed', e);
      rethrow;
    }
  }

  Future<DiseaseDetectionResult> _runDiseaseDetection(Uint8List inputBuffer) async {
    if (_diseaseDetector == null) {
      throw StateError('Disease detector not loaded');
    }

    try {
      final input = [inputBuffer];
      final output = [Float32List(diseaseClasses.length)];
      
      final startTime = DateTime.now();
      _diseaseDetector!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      final probabilities = output[0];
      final detectedIssues = <DetectedIssue>[];

      // Find issues above threshold
      const threshold = 0.3;
      for (int i = 0; i < diseaseClasses.length - 1; i++) { // Exclude "healthy" class
        if (probabilities[i] > threshold) {
          detectedIssues.add(DetectedIssue(
            disease: diseaseClasses[i],
            confidence: probabilities[i] * 100,
            severity: _calculateSeverity(probabilities[i]),
            recommendation: _getDiseaseRecommendation(diseaseClasses[i]),
          ));
        }
      }

      // Safety score is the "healthy" class probability
      final safetyScore = probabilities[diseaseClasses.length - 1] * 100;

      return DiseaseDetectionResult(
        detectedIssues: detectedIssues,
        safetyScore: safetyScore,
        healthStatus: safetyScore > 80 ? 'ปลอดภัย' : 'พบปัญหา',
        inferenceTimeMs: inferenceTime,
      );

    } catch (e) {
      AppLogger.error('Disease detection failed', e);
      rethrow;
    }
  }

  Future<MaturityAssessmentResult> _runMaturityAssessment(Uint8List inputBuffer) async {
    if (_maturityAssessor == null) {
      throw StateError('Maturity assessor not loaded');
    }

    try {
      final input = [inputBuffer];
      final output = [Float32List(2)]; // [maturity_score, harvest_readiness]
      
      final startTime = DateTime.now();
      _maturityAssessor!.run(input, output);
      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;

      final results = output[0];
      final maturityScore = results[0];
      final harvestReadiness = results[1];

      final maturityStage = _getMaturityStage(maturityScore);
      final daysToOptimal = _estimateDaysToHarvest(maturityScore);

      return MaturityAssessmentResult(
        maturityScore: maturityScore * 100,
        harvestReadiness: harvestReadiness * 100,
        maturityStage: maturityStage,
        optimalHarvest: harvestReadiness > 0.8,
        daysToOptimal: daysToOptimal,
        inferenceTimeMs: inferenceTime,
      );

    } catch (e) {
      AppLogger.error('Maturity assessment failed', e);
      rethrow;
    }
  }

  // Helper methods
  int _argMax(List<double> list) {
    double maxValue = list[0];
    int maxIndex = 0;
    
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }
    
    return maxIndex;
  }

  String _calculateQualityGrade(double quality, double contamination, double freshness) {
    if (quality > 0.9 && contamination < 0.1 && freshness > 0.8) {
      return 'A+';
    } else if (quality > 0.8 && contamination < 0.2 && freshness > 0.7) {
      return 'A';
    } else if (quality > 0.7 && contamination < 0.3 && freshness > 0.6) {
      return 'B';
    } else if (quality > 0.6 && contamination < 0.4 && freshness > 0.5) {
      return 'C';
    } else {
      return 'D';
    }
  }

  String _calculateSeverity(double confidence) {
    if (confidence > 0.7) return 'สูง';
    if (confidence > 0.5) return 'ปานกลาง';
    return 'ต่ำ';
  }

  String _getMaturityStage(double maturityScore) {
    if (maturityScore < 0.25) return 'อ่อน';
    if (maturityScore < 0.5) return 'กำลังเจริญ';
    if (maturityScore < 0.75) return 'สุก';
    return 'แก่เกิน';
  }

  int _estimateDaysToHarvest(double maturityScore) {
    if (maturityScore > 0.8) return 0;
    if (maturityScore > 0.6) return 7;
    if (maturityScore > 0.4) return 14;
    return 21;
  }

  String _getDiseaseRecommendation(String disease) {
    const recommendations = {
      'เชื้อราขาว': 'ลดความชื้น ปรับปรุงการระบายอากาศ',
      'เชื้อราดำ': 'ตรวจสอบการเก็บรักษา ทำความสะอาดพื้นที่',
      'แบคทีเรีย': 'ปรับปรุงสุขอนามัย ใช้น้ำสะอาด',
      'ไวรัส': 'แยกพืชที่ติดเชื้อ ควบคุมแมลงนำโรค',
      'แมลงศัตรูพืช': 'ใช้วิธีป้องกันแมลงที่เหมาะสม',
      'ความชื้นสูง': 'ปรับปรุงการระบายน้ำและอากาศ',
      'แสงแดดเกิน': 'จัดหาร่มเงาที่เหมาะสม',
      'ขาดธาตุอาหาร': 'เพิ่มปุ่ยที่เหมาะสมตามการวิเคราะห์ดิน',
      'สารเคมีตกค้าง': 'หยุดใช้สารเคมี ล้างทำความสะอาด',
    };
    return recommendations[disease] ?? 'ปรึกษาผู้เชี่ยวชาญ';
  }

  GacpComplianceResult _evaluateGacpCompliance(
    HerbClassificationResult herbResult,
    QualityAssessmentResult qualityResult,
    DiseaseDetectionResult diseaseResult,
  ) {
    double score = 0;
    final issues = <String>[];

    // Species identification (20%)
    if (herbResult.confidence > 95) {
      score += 20;
    } else if (herbResult.confidence > 90) {
      score += 15;
    } else {
      issues.add('ความแม่นยำในการระบุสายพันธุ์ต่ำ');
    }

    // Quality assessment (40%)
    if (qualityResult.overallScore > 80) {
      score += 40;
    } else if (qualityResult.overallScore > 70) {
      score += 30;
    } else {
      issues.add('คุณภาพไม่ผ่านมาตรฐาน GACP');
    }

    // Disease/contamination (30%)
    if (diseaseResult.safetyScore > 90) {
      score += 30;
    } else if (diseaseResult.safetyScore > 80) {
      score += 20;
    } else {
      issues.add('พบสารปนเปื้อนหรือโรคพืช');
    }

    // Documentation completeness (10%)
    score += 10; // Assume complete for now

    final status = score >= 80 ? 'ผ่าน' : 'ไม่ผ่าน';

    return GacpComplianceResult(
      score: score,
      status: status,
      issues: issues,
      certificateReady: status == 'ผ่าน',
    );
  }

  List<String> _generateRecommendations(
    HerbClassificationResult herbResult,
    QualityAssessmentResult qualityResult,
    DiseaseDetectionResult diseaseResult,
    MaturityAssessmentResult maturityResult,
  ) {
    final recommendations = <String>[];

    // Confidence recommendations
    if (herbResult.confidence < 95) {
      recommendations.add('ปรับปรุงคุณภาพภาพถ่ายหรือมุมมองการถ่าย');
    }

    // Quality recommendations
    if (qualityResult.overallScore < 80) {
      recommendations.add('ปรับปรุงเงื่อนไขการเก็บรักษาและการขนส่ง');
    }

    if (qualityResult.contaminationLevel > 20) {
      recommendations.add('ตรวจสอบและแก้ไขแหล่งที่มาของการปนเปื้อน');
    }

    // Disease recommendations
    for (final issue in diseaseResult.detectedIssues) {
      recommendations.add('แก้ไขปัญหา: ${issue.recommendation}');
    }

    // Maturity recommendations
    if (!maturityResult.optimalHarvest) {
      if (maturityResult.daysToOptimal > 0) {
        recommendations.add('รอการเก็บเกี่ยวอีก ${maturityResult.daysToOptimal} วัน');
      } else {
        recommendations.add('ควรเก็บเกี่ยวโดยเร็วที่สุด');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('คุณภาพดีเยี่ยม พร้อมสำหรับการรับรอง GACP');
    }

    return recommendations;
  }

  String _generateAnalysisId() {
    return 'analysis_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Batch analysis for multiple images
  Future<List<AnalysisResult>> analyzeBatch(List<File> imageFiles) async {
    final results = <AnalysisResult>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final result = await analyzeImage(imageFiles[i]);
        results.add(result);
        
        AppLogger.info('Batch progress: ${i + 1}/${imageFiles.length}');
      } catch (e) {
        AppLogger.error('Failed to analyze image ${imageFiles[i].path}', e);
        // Continue with next image
      }
    }
    
    return results;
  }

  // Get model performance stats
  Map<String, dynamic> getModelStats() {
    return {
      'initialized': _isInitialized,
      'models_loaded': {
        'herb_classifier': _herbClassifier != null,
        'quality_detector': _qualityDetector != null,
        'disease_detector': _diseaseDetector != null,
        'maturity_assessor': _maturityAssessor != null,
      },
      'supported_herbs': herbClasses,
      'supported_diseases': diseaseClasses,
    };
  }

  // Cleanup resources
  void dispose() {
    _herbClassifier?.close();
    _qualityDetector?.close();
    _diseaseDetector?.close();
    _maturityAssessor?.close();
    
    _herbClassifier = null;
    _qualityDetector = null;
    _diseaseDetector = null;
    _maturityAssessor = null;
    
    _isInitialized = false;
    AppLogger.info('🧹 AI Service disposed');
  }
}

// Custom delegate for optimization (Android)
class XNNPackDelegate extends Delegate {
  @override
  Map<String, dynamic> get options => {
    'threads': 4,
  };
}