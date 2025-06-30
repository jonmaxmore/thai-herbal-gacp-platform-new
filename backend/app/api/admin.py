from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.admin import AdminUserResponse
from app.services.admin_service import AdminService
from app.dependencies import get_admin_user

router = APIRouter(prefix="/admin", tags=["admin"])

@router.get("/users", response_model=list[AdminUserResponse], status_code=200)
async def list_users(
    service: AdminService = Depends(),
    admin=Depends(get_admin_user)
):
    """
    ดึงรายชื่อผู้ใช้ทั้งหมด (admin เท่านั้น)
    """
    users = await service.list_users()
    return users

@router.delete("/user/{user_id}", status_code=204)
async def delete_user(
    user_id: str,
    service: AdminService = Depends(),
    admin=Depends(get_admin_user)
):
    """
    ลบผู้ใช้ตาม user_id (admin เท่านั้น)
    """
    success = await service.delete_user(user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return None