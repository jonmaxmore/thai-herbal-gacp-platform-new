import logging
import sys
from typing import Optional

def get_logger(
    name: Optional[str] = None,
    level: int = logging.INFO,
    log_to_file: Optional[str] = None,
    fmt: str = "%(asctime)s %(levelname)s %(name)s %(process)d %(thread)d %(message)s",
    max_bytes: int = 10 * 1024 * 1024,
    backup_count: int = 10
) -> logging.Logger:
    """
    Production-ready logger factory.
    - name: logger name (default: root)
    - level: logging level (default: INFO)
    - log_to_file: file path to log to (if None, log to stdout)
    - fmt: log format
    - max_bytes: max log file size before rotation (default: 10MB)
    - backup_count: number of rotated log files to keep (default: 10)
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)
    formatter = logging.Formatter(fmt)

    # Remove all handlers if already set (avoid duplicate logs)
    if logger.hasHandlers():
        logger.handlers.clear()

    if log_to_file:
        from logging.handlers import RotatingFileHandler
        file_handler = RotatingFileHandler(
            log_to_file, maxBytes=max_bytes, backupCount=backup_count, encoding="utf-8"
        )
        file_handler.setFormatter(formatter)
        file_handler.setLevel(level)
        logger.addHandler(file_handler)
    # Always add stream handler for stdout (for containerized/cloud logging)
    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)
    stream_handler.setLevel(level)
    logger.addHandler(stream_handler)

    logger.propagate = False
    return logger

# Example usage for production:
# logger = get_logger("gacp", level=logging.INFO, log_to_file="/app/logs/app.log")