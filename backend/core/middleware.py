from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
import logging

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        logger = logging.getLogger("uvicorn.access")
        logger.info(f"Request: {request.method} {request.url}")
        response = await call_next(request)
        logger.info(f"Response status: {response.status_code}")
        return response

def setup_middlewares(app):
    app.add_middleware(LoggingMiddleware)