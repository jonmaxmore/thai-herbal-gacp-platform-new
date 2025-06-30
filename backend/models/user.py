from sqlalchemy import Column, String, Integer, DateTime, Boolean, func
from sqlalchemy.orm import relationship
from backend.core.database import Base

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(150), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_admin = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    certificates = relationship("Certificate", back_populates="user", cascade="all, delete-orphan")
    analyses = relationship("Analysis", back_populates="user", cascade="all, delete-orphan")
    trackings = relationship("Tracking", back_populates="user", cascade="all, delete-orphan")

# หมายเหตุ:
# - ใช้ relationship แบบสองทางกับ Certificate, Analysis, Tracking
# - ใช้ cascade="all, delete-orphan" เพื่อ integrity ของข้อมูล
# - มี unique constraint, index, timestamp, และ field ที่เหมาะสม
# - ไม่มี conflict กับระบบอื่น
# - พร้อมสำหรับ production, maintain ง่าย, ORM discovery ครบถ้วน
