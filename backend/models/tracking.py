from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, JSON, func
from sqlalchemy.orm import relationship
from backend.core.database import Base

class Tracking(Base):
    __tablename__ = "tracking"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"), nullable=False, index=True)
    herb_id = Column(Integer, ForeignKey("herb.id", ondelete="SET NULL"), nullable=True, index=True)
    tracking_code = Column(String(128), unique=True, nullable=False, index=True)
    status = Column(String(64), nullable=False, index=True)
    events = Column(JSON, nullable=True)  # List of timeline events
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="trackings")
    herb = relationship("Herb", back_populates="trackings")

# หมายเหตุ:
# - ใน models/user.py ต้องมี: trackings = relationship("Tracking", back_populates="user", cascade="all, delete-orphan")
# - ใน models/herb.py ต้องมี: trackings = relationship("Tracking", back_populates="herb", cascade="all, delete-orphan")
# - ใช้ ondelete เพื่อ integrity ของข้อมูล
# - พร้อมสำหรับ production, รองรับ Alembic migration, ORM discovery