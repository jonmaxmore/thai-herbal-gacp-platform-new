from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.certificate import CertificateApplyRequest, CertificateResponse
from app.services.certificate_service import CertificateService
from app.dependencies import get_current_user
import logging

router = APIRouter(prefix="/certificates", tags=["certificates"])

@router.post("/apply", response_model=CertificateResponse, status_code=201)
async def apply_certificate(
    request: CertificateApplyRequest,
    user=Depends(get_current_user),
    service: CertificateService = Depends()
):
    """
    ยื่นขอใบรับรอง (ต้อง login)
    """
    try:
        result = await service.apply_certificate(request, user)
        if not result.is_success:
            logging.warning(f"Certificate apply failed for user {user.id}: {result.message}")
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=result.message)
        logging.info(f"User {user.id} applied for certificate successfully")
        return result
    except Exception as e:
        logging.error(f"Certificate apply error: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Certificate apply failed")

@router.get("/status", response_model=list[CertificateResponse], status_code=200)
async def get_certificate_status(
    user=Depends(get_current_user),
    service: CertificateService = Depends()
):
    """
    ตรวจสอบสถานะใบรับรองของผู้ใช้ (ต้อง login)
    """
    try:
        certificates = await service.get_certificates_by_user(user.id)
        return certificates
    except Exception as e:
        logging.error(f"Get certificate status error for user {user.id}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Cannot get certificate status")