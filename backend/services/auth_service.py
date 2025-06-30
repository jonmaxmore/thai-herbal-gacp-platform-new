from fastapi import Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from jose import JWTError
from app.schemas.auth import LoginRequest, LoginResponse, UserResponse
from backend.core.database import get_db
from backend.core.security import verify_password, create_access_token, decode_access_token
from backend.models.user import User
from sqlalchemy.future import select
from typing import Optional
import logging

class AuthService:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db

    async def login(self, request: LoginRequest) -> LoginResponse:
        stmt = select(User).where(User.username == request.username)
        result = await self.db.execute(stmt)
        user: Optional[User] = result.scalar_one_or_none()
        if not user or not verify_password(request.password, user.hashed_password):
            return LoginResponse(is_success=False, message="Invalid username or password")
        if not user.is_active:
            return LoginResponse(is_success=False, message="User is inactive")
        access_token = create_access_token({"sub": str(user.id)})
        return LoginResponse(
            is_success=True,
            message="Login successful",
            access_token=access_token,
            user=UserResponse(
                id=user.id,
                username=user.username,
                email=user.email,
                full_name=user.full_name,
                is_admin=user.is_admin
            )
        )

    @staticmethod
    async def get_current_user(request: Request, db: AsyncSession = Depends(get_db)) -> UserResponse:
        """
        Extract and validate user from JWT token in Authorization header.
        """
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            raise credentials_exception
        token = auth_header.split(" ")[1]
        try:
            payload = decode_access_token(token)
            if payload is None or "sub" not in payload:
                raise credentials_exception
            user_id = int(payload["sub"])
        except JWTError as e:
            logging.warning(f"JWT decode error: {e}")
            raise credentials_exception
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user: Optional[User] = result.scalar_one_or_none()
        if not user or not user.is_active:
            raise credentials_exception
        return UserResponse(
            id=user.id,
            username=user.username,
            email=user.email,
            full_name=user.full_name,
            is_admin=user.is_admin
        )