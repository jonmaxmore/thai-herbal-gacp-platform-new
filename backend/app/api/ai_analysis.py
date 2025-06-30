from fastapi import APIRouter, UploadFile, File, HTTPException, status, Depends
from app.schemas.ai import AIAnalysisResponse
from app.services.ai_service import AIService
from app.dependencies import get_current_user
import logging

router = APIRouter(prefix="/ai", tags=["ai"])

@router.post("/analyze", response_model=AIAnalysisResponse, status_code=200)
async def analyze_image(
    file: UploadFile = File(...),
    user=Depends(get_current_user),
    service: AIService = Depends()
):
    """
    วิเคราะห์ภาพด้วย AI (ต้อง login)
    """
    try:
        result = await service.analyze(file, user)
        return result
    except ValueError as ve:
        logging.warning(f"AI analysis input error: {ve}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logging.error(f"AI analysis failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="AI analysis failed")