from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, JSON, func
from sqlalchemy.orm import relationship
from backend.core.database import Base

class Analysis(Base):
    __tablename__ = "analysis"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"), nullable=False, index=True)
    image_path = Column(String(512), nullable=False)
    herb_id = Column(Integer, ForeignKey("herb.id", ondelete="SET NULL"), nullable=True, index=True)
    result = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="analyses")
    herb = relationship("Herb", back_populates="analyses")

# หมายเหตุ:
# - ใน models/user.py ต้องมี: analyses = relationship("Analysis", back_populates="user", cascade="all, delete-orphan")
# - ใน models/herb.py ต้องมี: analyses = relationship("Analysis", back_populates="herb", cascade="all, delete-orphan")
# - ใช้ ondelete เพื่อ integrity ของข้อมูล
# - พร้อมสำหรับ production, รองรับ Alembic migration, ORM discovery