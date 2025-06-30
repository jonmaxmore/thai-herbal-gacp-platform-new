from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import logging
import uvicorn
import os
from pathlib import Path

from app.core.config import settings
from app.core.database import engine, Base
from app.api import api_router
from app.services.ai_service import AIService

# Logging config for production
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)

# Create tables (sync for first-time setup, use Alembic for migrations in production)
try:
    Base.metadata.create_all(bind=engine)
    logging.info("Database tables created or verified.")
except Exception as e:
    logging.error(f"Database initialization failed: {e}")

# Lifespan events
@asynccontextmanager
async def lifespan(app: FastAPI):
    logging.info("🚀 Starting GACP Herbal AI Platform...")
    await AIService.initialize()
    logging.info("✅ AI Models loaded successfully")
    yield
    logging.info("🛑 Shutting down...")
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

# CORS middleware (configure allowed origins for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ALLOW_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static files
static_dir = os.getenv("STATIC_DIR", "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Include all routers via api_router
app.include_router(api_router, prefix="/api")

@app.get("/", tags=["root"])
async def root():
    return {
        "message": "GACP Herbal AI Platform API",
        "version": "1.0.0",
        "platforms": ["mobile", "desktop", "web"],
        "status": "operational"
    }

@app.get("/health", tags=["health"])
async def health_check():
    return {"status": "healthy", "ai_models": await AIService.get_status()}

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        log_level="info",
        workers=int(os.getenv("UVICORN_WORKERS", 1)),
        reload=os.getenv("ENVIRONMENT", "development") == "development"
    )