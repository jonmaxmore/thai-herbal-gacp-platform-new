# app/services/ai_service.py
import onnxruntime as ort
import numpy as np
from PIL import Image
import io
import asyncio
from typing import Dict, List, Optional
from pathlib import Path

class AIService:
    _herb_classifier = None
    _quality_detector = None
    _disease_detector = None
    _maturity_assessor = None
    
    @classmethod
    async def initialize(cls):
        """Initialize all AI models"""
        try:
            model_path = Path("app/ai_models")
            
            # Load models with ONNX Runtime
            cls._herb_classifier = ort.InferenceSession(
                str(model_path / "herb_classifier_v2.onnx"),
                providers=['CPUExecutionProvider']
            )
            
            cls._quality_detector = ort.InferenceSession(
                str(model_path / "quality_detector_v2.onnx"),
                providers=['CPUExecutionProvider']
            )
            
            cls._disease_detector = ort.InferenceSession(
                str(model_path / "disease_detector_v2.onnx"),
                providers=['CPUExecutionProvider']
            )
            
            cls._maturity_assessor = ort.InferenceSession(
                str(model_path / "maturity_assessor_v1.onnx"),
                providers=['CPUExecutionProvider']
            )
            
            print("✅ All AI models loaded successfully")
            
        except Exception as e:
            print(f"❌ Error loading AI models: {e}")
            raise e
    
    @classmethod
    async def analyze_herb_image(cls, image_bytes: bytes) -> Dict:
        """Comprehensive herb analysis"""
        # Preprocess image
        image = cls._preprocess_image(image_bytes)
        
        # Run all models
        herb_result = await cls._classify_herb(image)
        quality_result = await cls._assess_quality(image)
        disease_result = await cls._detect_diseases(image)
        maturity_result = await cls._assess_maturity(image)
        
        # Combine results
        analysis = {
            "herb_identification": herb_result,
            "quality_assessment": quality_result,
            "disease_detection": disease_result,
            "maturity_assessment": maturity_result,
            "gacp_compliance": cls._evaluate_gacp_compliance(
                herb_result, quality_result, disease_result
            ),
            "recommendations": cls._generate_recommendations(
                herb_result, quality_result, disease_result, maturity_result
            )
        }
        
        return analysis
    
    @classmethod
    def _preprocess_image(cls, image_bytes: bytes) -> np.ndarray:
        """Preprocess image for AI models"""
        image = Image.open(io.BytesIO(image_bytes))
        image = image.convert('RGB')
        image = image.resize((224, 224))
        
        # Normalize to [-1, 1]
        image_array = np.array(image).astype(np.float32)
        image_array = (image_array / 127.5) - 1.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
    
    @classmethod
    async def _classify_herb(cls, image: np.ndarray) -> Dict:
        """Classify herb species"""
        input_name = cls._herb_classifier.get_inputs()[0].name
        output = cls._herb_classifier.run(None, {input_name: image})[0]
        
        herb_classes = [
            "กัญชา (Cannabis sativa)",
            "ขมิ้นชัน (Curcuma longa)", 
            "ขิง (Zingiber officinale)",
            "กระชายดำ (Kaempferia parviflora)",
            "ไพล (Zingiber cassumunar)",
            "กระท่อม (Mitragyna speciosa)"
        ]
        
        probabilities = output[0]
        predicted_idx = np.argmax(probabilities)
        confidence = float(probabilities[predicted_idx])
        
        return {
            "species": herb_classes[predicted_idx],
            "confidence": confidence * 100,
            "all_probabilities": {
                herb_classes[i]: float(probabilities[i]) * 100 
                for i in range(len(herb_classes))
            }
        }
    
    @classmethod
    async def _assess_quality(cls, image: np.ndarray) -> Dict:
        """Assess overall quality"""
        input_name = cls._quality_detector.get_inputs()[0].name
        output = cls._quality_detector.run(None, {input_name: image})[0]
        
        quality_score = float(output[0][0])
        contamination_score = float(output[0][1])
        freshness_score = float(output[0][2])
        
        overall_grade = cls._calculate_quality_grade(
            quality_score, contamination_score, freshness_score
        )
        
        return {
            "overall_score": quality_score * 100,
            "contamination_level": contamination_score * 100,
            "freshness_score": freshness_score * 100,
            "grade": overall_grade,
            "gacp_compliant": quality_score > 0.8 and contamination_score < 0.2
        }
    
    @classmethod
    async def _detect_diseases(cls, image: np.ndarray) -> Dict:
        """Detect diseases and defects"""
        input_name = cls._disease_detector.get_inputs()[0].name
        output = cls._disease_detector.run(None, {input_name: image})[0]
        
        disease_classes = [
            "เชื้อราขาว", "เชื้อราดำ", "แบคทีเรีย", "ไวรัส",
            "แมลงศัตรูพืช", "ความชื้นสูง", "แสงแดดเกิน",
            "ขาดธาตุอาหาร", "สารเคมีตกค้าง", "ปลอดภัย"
        ]
        
        probabilities = output[0]
        detected_issues = []
        
        for i, prob in enumerate(probabilities):
            if prob > 0.3 and disease_classes[i] != "ปลอดภัย":
                detected_issues.append({
                    "issue": disease_classes[i],
                    "severity": float(prob) * 100,
                    "recommendation": cls._get_disease_recommendation(disease_classes[i])
                })
        
        return {
            "issues_detected": detected_issues,
            "health_status": "ปลอดภัย" if not detected_issues else "มีปัญหา",
            "safety_score": float(probabilities[-1]) * 100
        }
    
    @classmethod
    async def _assess_maturity(cls, image: np.ndarray) -> Dict:
        """Assess maturity/harvest readiness"""
        input_name = cls._maturity_assessor.get_inputs()[0].name
        output = cls._maturity_assessor.run(None, {input_name: image})[0]
        
        maturity_score = float(output[0][0])
        harvest_readiness = float(output[0][1])
        
        maturity_stages = ["อ่อน", "กำลังเจริญ", "สุก", "แก่เกิน"]
        stage_idx = min(int(maturity_score * 4), 3)
        
        return {
            "maturity_score": maturity_score * 100,
            "harvest_readiness": harvest_readiness * 100,
            "stage": maturity_stages[stage_idx],
            "optimal_harvest": harvest_readiness > 0.8,
            "days_to_optimal": cls._estimate_days_to_harvest(maturity_score)
        }
    
    @classmethod
    def _calculate_quality_grade(cls, quality: float, contamination: float, freshness: float) -> str:
        """Calculate overall quality grade"""
        if quality > 0.9 and contamination < 0.1 and freshness > 0.8:
            return "A+"
        elif quality > 0.8 and contamination < 0.2 and freshness > 0.7:
            return "A"
        elif quality > 0.7 and contamination < 0.3 and freshness > 0.6:
            return "B"
        elif quality > 0.6 and contamination < 0.4 and freshness > 0.5:
            return "C"
        else:
            return "D"
    
    @classmethod
    def _evaluate_gacp_compliance(cls, herb_result: Dict, quality_result: Dict, disease_result: Dict) -> Dict:
        """Evaluate GACP compliance"""
        compliance_score = 0
        issues = []
        
        # Species identification confidence (20%)
        if herb_result["confidence"] > 95:
            compliance_score += 20
        elif herb_result["confidence"] > 90:
            compliance_score += 15
        else:
            issues.append("ความแม่นยำในการระบุสายพันธุ์ต่ำ")
        
        # Quality assessment (40%)
        if quality_result["overall_score"] > 80:
            compliance_score += 40
        elif quality_result["overall_score"] > 70:
            compliance_score += 30
        else:
            issues.append("คุณภาพไม่ผ่านมาตรฐาน GACP")
        
        # Disease/contamination (30%)
        if disease_result["safety_score"] > 90:
            compliance_score += 30
        elif disease_result["safety_score"] > 80:
            compliance_score += 20
        else:
            issues.append("พบสารปนเปื้อนหรือโรคพืช")
        
        # Documentation completeness (10%)
        compliance_score += 10  # Assume complete for demo
        
        status = "ผ่าน" if compliance_score >= 80 else "ไม่ผ่าน"
        
        return {
            "score": compliance_score,
            "status": status,
            "issues": issues,
            "certificate_ready": status == "ผ่าน"
        }
    
    @classmethod
    def _generate_recommendations(cls, herb_result: Dict, quality_result: Dict, 
                                disease_result: Dict, maturity_result: Dict) -> List[str]:
        """Generate actionable recommendations"""
        recommendations = []
        
        # Confidence recommendations
        if herb_result["confidence"] < 95:
            recommendations.append("ปรับปรุงคุณภาพภาพถ่ายหรือมุมมองการถ่าย")
        
        # Quality recommendations
        if quality_result["overall_score"] < 80:
            recommendations.append("ปรับปรุงเงื่อนไขการเก็บรักษาและการขนส่ง")
        
        if quality_result["contamination_level"] > 20:
            recommendations.append("ตรวจสอบและแก้ไขแหล่งที่มาของการปนเปื้อน")
        
        # Disease recommendations
        for issue in disease_result["issues_detected"]:
            recommendations.append(f"แก้ไขปัญหา: {issue['recommendation']}")
        
        # Maturity recommendations
        if not maturity_result["optimal_harvest"]:
            if maturity_result["days_to_optimal"] > 0:
                recommendations.append(f"รอการเก็บเกี่ยวอีก {maturity_result['days_to_optimal']} วัน")
            else:
                recommendations.append("ควรเก็บเกี่ยวโดยเร็วที่สุด")
        
        if not recommendations:
            recommendations.append("คุณภาพดีเยี่ยม พร้อมสำหรับการรับรอง GACP")
        
        return recommendations
    
    @classmethod
    def _get_disease_recommendation(cls, disease: str) -> str:
        """Get specific recommendation for each disease"""
        recommendations = {
            "เชื้อราขาว": "ลดความชื้น ปรับปรุงการระบายอากาศ",
            "เชื้อราดำ": "ตรวจสอบการเก็บรักษา ทำความสะอาดพื้นที่",
            "แบคทีเรีย": "ปรับปรุงสุขอนามัย ใช้น้ำสะอาด",
            "ไวรัส": "แยกพืชที่ติดเชื้อ ควบคุมแมลงนำโรค",
            "แมลงศัตรูพืช": "ใช้วิธีป้องกันแมลงที่เหมาะสม",
            "ความชื้นสูง": "ปรับปรุงการระบายน้ำและอากาศ",
            "แสงแดดเกิน": "จัดหาร่มเงาที่เหมาะสม",
            "ขาดธาตุอาหาร": "เพิ่มปุ่ยที่เหมาะสมตามการวิเคราะห์ดิน",
            "สารเคมีตกค้าง": "หยุดใช้สารเคมี ล้างทำความสะอาด"
        }
        return recommendations.get(disease, "ปรึกษาผู้เชี่ยวชาญ")
    
    @classmethod
    def _estimate_days_to_harvest(cls, maturity_score: float) -> int:
        """Estimate days until optimal harvest"""
        if maturity_score > 0.8:
            return 0
        elif maturity_score > 0.6:
            return 7
        elif maturity_score > 0.4:
            return 14
        else:
            return 21
    
    @classmethod
    async def get_status(cls) -> Dict:
        """Get AI service status"""
        return {
            "herb_classifier": cls._herb_classifier is not None,
            "quality_detector": cls._quality_detector is not None,
            "disease_detector": cls._disease_detector is not None,
            "maturity_assessor": cls._maturity_assessor is not None,
            "ready": all([
                cls._herb_classifier is not None,
                cls._quality_detector is not None,
                cls._disease_detector is not None,
                cls._maturity_assessor is not None
            ])
        }
    
    @classmethod
    def cleanup(cls):
        """Cleanup resources"""
        # ONNX Runtime sessions are automatically cleaned up
        pass