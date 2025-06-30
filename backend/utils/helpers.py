import uuid
import datetime
import logging
from typing import Any, Dict, Optional, Union

def generate_uuid() -> str:
    """Generate a new UUID4 string."""
    return str(uuid.uuid4())

def now_utc() -> datetime.datetime:
    """Get current UTC datetime (timezone-aware)."""
    return datetime.datetime.now(datetime.timezone.utc)

def safe_get(d: Dict, key: Any, default: Any = None) -> Any:
    """Safely get a value from a dict with a default."""
    return d[key] if key in d else default

def log_exception(e: Exception, context: Optional[str] = None) -> None:
    """Log an exception with optional context and stack trace."""
    if context:
        logging.error(f"{context}: {e}", exc_info=True)
    else:
        logging.error(f"Exception: {e}", exc_info=True)

def format_datetime(dt: Union[datetime.datetime, None], fmt: str = "%Y-%m-%d %H:%M:%S") -> str:
    """Format a datetime object as string."""
    if not dt:
        return ""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.timezone.utc)
    return dt.strftime(fmt)

def is_valid_uuid(val: str) -> bool:
    """Check if a string is a valid UUID4."""
    try:
        uuid_obj = uuid.UUID(val, version=4)
        return str(uuid_obj) == val
    except Exception:
        return False

def to_utc(dt: datetime.datetime) -> datetime.datetime:
    """Convert a naive datetime to UTC timezone-aware."""
    if dt.tzinfo is None:
        return dt.replace(tzinfo=datetime.timezone.utc)
    return dt.astimezone(datetime.timezone.utc)

def parse_datetime(dt_str: str, fmt: str = "%Y-%m-%d %H:%M:%S") -> Optional[datetime.datetime]:
    """Parse a datetime string to a datetime object."""
    try:
        return datetime.datetime.strptime(dt_str, fmt).replace(tzinfo=datetime.timezone.utc)
    except Exception:
        return None

def deep_merge_dicts(a: Dict, b: Dict) -> Dict:
    """Recursively merge two dicts (b overrides a)."""
    result = a.copy()
    for k, v in b.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = deep_merge_dicts(result[k], v)
        else:
            result[k] = v
    return result

def dict_diff(a: Dict, b: Dict) -> Dict:
    """Return a dict of keys/values that differ between two dicts."""
    diff = {}
    for k in set(a.keys()).union(b.keys()):
        if a.get(k) != b.get(k):
            diff[k] = {"old": a.get(k), "new": b.get(k)}
    return diff