from fastapi import FastAPI, File, UploadFile, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import uvicorn
import os
from pathlib import Path

from app.core.config import settings
from app.core.database import engine, Base
from app.api import auth, ai_analysis, certificates, herbs, tracking, admin
from app.services.ai_service import AIService

# Create tables
Base.metadata.create_all(bind=engine)

# Lifespan events
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 Starting GACP Herbal AI Platform...")
    await AIService.initialize()
    print("✅ AI Models loaded successfully")
    yield
    # Shutdown
    print("🛑 Shutting down...")
    AIService.cleanup()

# Create FastAPI instance
app = FastAPI(
    title="GACP Herbal AI Platform API",
    description="Multiplatform API for Thai Herbal GACP Certification",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["authentication"])
app.include_router(ai_analysis.router, prefix="/api/ai", tags=["ai-analysis"])
app.include_router(certificates.router, prefix="/api/certificates", tags=["certificates"])
app.include_router(herbs.router, prefix="/api/herbs", tags=["herbs"])
app.include_router(tracking.router, prefix="/api/tracking", tags=["tracking"])
app.include_router(admin.router, prefix="/api/admin", tags=["admin"])

@app.get("/")
async def root():
    return {
        "message": "GACP Herbal AI Platform API",
        "version": "1.0.0",
        "platforms": ["mobile", "desktop", "web"],
        "status": "operational"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "ai_models": await AIService.get_status()}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )