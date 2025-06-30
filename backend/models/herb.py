from sqlalchemy import Column, String, Integer, DateTime, JSON, func
from sqlalchemy.orm import relationship
from backend.core.database import Base

class Herb(Base):
    __tablename__ = "herb"

    id = Column(Integer, primary_key=True, index=True)
    name_th = Column(String(255), nullable=False, unique=True, index=True)
    name_en = Column(String(255), nullable=True, index=True)
    scientific_name = Column(String(255), nullable=True, index=True)
    description = Column(String(1024), nullable=True)
    properties = Column(JSON, nullable=True)
    image_url = Column(String(512), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    analyses = relationship("Analysis", back_populates="herb", cascade="all, delete-orphan")
    trackings = relationship("Tracking", back_populates="herb", cascade="all, delete-orphan")

# หมายเหตุ:
# - ใน models/analysis.py ต้องมี: herb = relationship("Herb", back_populates="analyses")
# - ใน models/tracking.py ต้องมี: herb = relationship("Herb", back_populates="trackings")
# - ใช้ relationship และ cascade ที่เหมาะสมสำหรับ production
# - ไม่มี conflict กับระบบอื่น พร้อมสำหรับ Alembic migration และ ORM discovery
