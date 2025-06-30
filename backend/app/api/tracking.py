from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.tracking import TrackingEventResponse
from app.services.tracking_service import TrackingService
from app.dependencies import get_current_user
import logging

router = APIRouter(prefix="/tracking", tags=["tracking"])

@router.get("/timeline/{tracking_id}", response_model=list[TrackingEventResponse], status_code=200)
async def get_tracking_timeline(
    tracking_id: str,
    user=Depends(get_current_user),
    service: TrackingService = Depends()
):
    """
    ดึงไทม์ไลน์การติดตามด้วย tracking_id (ต้อง login)
    """
    try:
        events = await service.get_timeline(tracking_id, user)
        if not events:
            logging.warning(f"Tracking not found: {tracking_id} by user {user.id}")
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tracking not found")
        return events
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Failed to get tracking timeline {tracking_id}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Cannot get tracking timeline")