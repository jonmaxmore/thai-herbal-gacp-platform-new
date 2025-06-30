from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Enum, JSON, func
from sqlalchemy.orm import relationship
from backend.core.database import Base
import enum

class CertificateStatus(enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    REVOKED = "revoked"

class Certificate(Base):
    __tablename__ = "certificate"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"), nullable=False, index=True)
    certificate_type = Column(String(128), nullable=False)
    data = Column(JSON, nullable=True)
    status = Column(Enum(CertificateStatus), default=CertificateStatus.PENDING, nullable=False)
    issued_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    note = Column(String(512), nullable=True)

    user = relationship("User", back_populates="certificates")

# หมายเหตุ:
# - ใน models/user.py ต้องมี: certificates = relationship("Certificate", back_populates="user", cascade="all, delete-orphan")
# - ใช้ ondelete="CASCADE" เพื่อ integrity ของข้อมูล
# - พร้อมสำหรับ production, รองรับ Alembic migration, ORM discovery