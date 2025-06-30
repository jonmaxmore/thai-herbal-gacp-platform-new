"""
GACP Herbal AI Platform - Main FastAPI Application
Production-ready backend with comprehensive features
"""

import asyncio
import logging
import os
import sys
from contextlib import asynccontextmanager
from pathlib import Path

import uvicorn
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

# Import core modules
from app.core.config import settings
from app.core.database import engine, Base, get_db
from app.core.security import verify_api_key
from app.core.monitoring import MonitoringMiddleware, system_monitor
from app.core.exceptions import (
    CustomHTTPException,
    custom_http_exception_handler,
    validation_exception_handler,
    python_exception_handler
)

# Import services
from app.services.ai_service import AIService
from app.services.notification_service import NotificationService
from app.services.cache_service import CacheService

# Import API routers
from app.api.v1 import (
    auth,
    users,
    herbs,
    ai_analysis,
    certificates,
    tracking,
    admin,
    health
)

from backend.utils.logger import get_logger

# Configure logging (production-ready, log rotation, stdout + file)
logger = get_logger(
    name="gacp",
    level=logging.INFO,
    log_to_file="logs/app.log",
    fmt="%(asctime)s %(levelname)s %(name)s %(process)d %(thread)d %(message)s",
    max_bytes=20 * 1024 * 1024,
    backup_count=10
)

# Rate limiting
limiter = Limiter(key_func=get_remote_address)

# Application lifespan events
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown events"""
    logger.info("🚀 Starting GACP Herbal AI Platform...")
    try:
        # Create database tables
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created")
        # Initialize services
        await AIService.initialize()
        logger.info("✅ AI Service initialized")
        await NotificationService.initialize()
        logger.info("✅ Notification Service initialized")
        await CacheService.initialize()
        logger.info("✅ Cache Service initialized")
        # Start system monitoring
        asyncio.create_task(system_monitor.start_monitoring())
        logger.info("✅ System monitoring started")
        logger.info("🎉 Application startup completed")
    except Exception as e:
        logger.error(f"❌ Application startup failed: {e}", exc_info=True)
        raise e
    yield
    # Shutdown
    logger.info("🛑 Shutting down application...")
    try:
        system_monitor.stop_monitoring()
        AIService.cleanup()
        await CacheService.cleanup()
        logger.info("✅ Application shutdown completed")
    except Exception as e:
        logger.error(f"❌ Application shutdown error: {e}", exc_info=True)

# Create FastAPI application
app = FastAPI(
    title="GACP Herbal AI Platform API",
    description="""
    ## GACP Herbal AI Platform - Production API

    Advanced AI-powered platform for Thai herbal plant GACP certification.

    ### Features
    - 🤖 AI-powered herb identification and quality assessment
    - 📱 Multi-platform support (Mobile, Desktop, Web)
    - 🔐 Secure authentication and authorization
    - 📊 Real-time analytics and monitoring
    - 🏥 GACP compliance verification
    - 📋 Certificate management system
    - 🔍 Complete track & trace functionality

    ### Authentication
    Most endpoints require Bearer token authentication.
    API key authentication is available for system integrations.

    ### Rate Limiting
    - Authenticated users: 1000 requests/hour
    - Anonymous users: 100 requests/hour
    - AI analysis: 50 requests/hour per user

    ### Support
    - Documentation: `/docs` (Swagger UI)
    - ReDoc: `/redoc`
    - Health Check: `/health`
    - Metrics: `/metrics` (Prometheus format)
    """,
    version="2.0.0",
    contact={
        "name": "Predictive AI Solution Co., Ltd.",
        "email": "support@predictive-ai.co.th",
        "url": "https://www.predictive-ai.co.th"
    },
    license_info={
        "name": "Proprietary License",
        "url": "https://www.predictive-ai.co.th/license"
    },
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
    openapi_url="/openapi.json" if settings.ENVIRONMENT != "production" else None,
    lifespan=lifespan,
)

# Security Middleware
if settings.ENVIRONMENT == "production":
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.ALLOWED_HOSTS
    )

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
    expose_headers=["X-Total-Count", "X-Rate-Limit-*"],
)

# Compression Middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Monitoring Middleware
app.add_middleware(MonitoringMiddleware)

# Rate Limiting Middleware
app.add_middleware(SlowAPIMiddleware)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Custom Exception Handlers
app.add_exception_handler(CustomHTTPException, custom_http_exception_handler)
app.add_exception_handler(422, validation_exception_handler)
app.add_exception_handler(Exception, python_exception_handler)

# Static files
static_path = Path("static")
static_path.mkdir(exist_ok=True)
app.mount("/static", StaticFiles(directory=static_path), name="static")

# API Routes
api_v1_prefix = "/api/v1"

app.include_router(
    health.router,
    prefix="/health",
    tags=["Health Check"]
)

app.include_router(
    auth.router,
    prefix=f"{api_v1_prefix}/auth",
    tags=["Authentication"]
)

app.include_router(
    users.router,
    prefix=f"{api_v1_prefix}/users",
    tags=["User Management"]
)

app.include_router(
    herbs.router,
    prefix=f"{api_v1_prefix}/herbs",
    tags=["Herb Database"]
)

app.include_router(
    ai_analysis.router,
    prefix=f"{api_v1_prefix}/analysis",
    tags=["AI Analysis"]
)

app.include_router(
    certificates.router,
    prefix=f"{api_v1_prefix}/certificates",
    tags=["GACP Certificates"]
)

app.include_router(
    tracking.router,
    prefix=f"{api_v1_prefix}/tracking",
    tags=["Tracking"]
)

app.include_router(
    admin.router,
    prefix=f"{api_v1_prefix}/admin",
    tags=["Admin"]
)

@app.get("/", tags=["root"])
async def root():
    return {
        "message": "GACP Herbal AI Platform API",
        "version": "2.0.0",
        "platforms": ["mobile", "desktop", "web"],
        "status": "operational"
    }

@app.get("/health", tags=["health"])
async def health_check():
    return {"status": "healthy", "ai_models": await AIService.get_status()}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        log_level="info",
        workers=int(os.getenv("UVICORN_WORKERS", 2))
    )