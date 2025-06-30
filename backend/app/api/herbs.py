from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.herb import HerbResponse
from app.services.herb_service import HerbService
import logging

router = APIRouter(prefix="/herbs", tags=["herbs"])

@router.get("/", response_model=list[HerbResponse], status_code=200)
async def list_herbs(service: HerbService = Depends()):
    """
    ดึงรายชื่อสมุนไพรทั้งหมด
    """
    try:
        herbs = await service.list_herbs()
        return herbs
    except Exception as e:
        logging.error(f"Failed to list herbs: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Cannot list herbs")

@router.get("/{herb_id}", response_model=HerbResponse, status_code=200)
async def get_herb(herb_id: str, service: HerbService = Depends()):
    """
    ดึงข้อมูลสมุนไพรตาม herb_id
    """
    try:
        herb = await service.get_herb(herb_id)
        if not herb:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Herb not found")
        return herb
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Failed to get herb {herb_id}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Cannot get herb")