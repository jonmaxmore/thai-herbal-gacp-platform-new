from fastapi import APIRouter, HTTPException, status, Depends
from app.schemas.auth import LoginRequest, LoginResponse, UserResponse
from app.services.auth_service import AuthService
import logging

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/login", response_model=LoginResponse, status_code=200)
async def login(request: LoginRequest, service: AuthService = Depends()):
    """
    เข้าสู่ระบบด้วย username/password
    """
    result = await service.login(request)
    if not result.is_success:
        logging.warning(f"Login failed for user: {request.username}")
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=result.message)
    logging.info(f"User logged in: {request.username}")
    return result

@router.get("/me", response_model=UserResponse, status_code=200)
async def get_me(user=Depends(AuthService.get_current_user)):
    """
    ดึงข้อมูลผู้ใช้ปัจจุบัน (ต้อง login)
    """
    return user