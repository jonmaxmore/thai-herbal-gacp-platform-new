# รวม router ทั้งหมดสำหรับ FastAPI app
from fastapi import APIRouter

from .auth import router as auth_router
from .certificates import router as certificates_router
from .herbs import router as herbs_router
from .tracking import router as tracking_router
from .ai_analysis import router as ai_router
from .admin import router as admin_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(certificates_router)
api_router.include_router(herbs_router)
api_router.include_router(tracking_router)
api_router.include_router(ai_router)
api_router.include_router(admin_router)

from app.api import api_router
app.include_router(api_router, prefix="/api/v1")