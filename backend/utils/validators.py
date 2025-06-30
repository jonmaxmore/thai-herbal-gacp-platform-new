import re
import datetime
from typing import Any, Optional, Sequence, Type

def is_valid_email(email: str) -> bool:
    """Check if the email address is valid (RFC 5322 simplified)."""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.fullmatch(pattern, email))

def is_strong_password(password: str, min_length: int = 8) -> bool:
    """
    Validate password strength.
    - At least min_length characters
    - Contains upper, lower, digit, and special char
    """
    if len(password) < min_length:
        return False
    if not re.search(r"[A-Z]", password):
        return False
    if not re.search(r"[a-z]", password):
        return False
    if not re.search(r"\d", password):
        return False
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
        return False
    return True

def is_valid_phone(phone: str) -> bool:
    """Check if the phone number is valid (Thai and international format)."""
    pattern = r"^(?:\+66|0)\d{8,9}$"
    return bool(re.fullmatch(pattern, phone))

def is_valid_date(date_str: str, fmt: str = "%Y-%m-%d") -> bool:
    """Check if the string is a valid date in the given format."""
    try:
        datetime.datetime.strptime(date_str, fmt)
        return True
    except Exception:
        return False

def is_positive_int(val: Any) -> bool:
    """Check if value is a positive integer."""
    try:
        return int(val) > 0
    except Exception:
        return False

def is_non_empty_str(val: Any) -> bool:
    """Check if value is a non-empty string."""
    return isinstance(val, str) and val.strip() != ""

def is_in_choices(val: Any, choices: Sequence) -> bool:
    """Check if value is in allowed choices."""
    return val in choices

def is_valid_url(url: str) -> bool:
    """Check if the string is a valid URL."""
    pattern = r"^(https?|ftp)://[^\s/$.?#].[^\s]*$"
    return bool(re.fullmatch(pattern, url))

def is_valid_thai_id_card(id_card: str) -> bool:
    """Validate Thai national ID card number."""
    if not re.fullmatch(r"\d{13}", id_card):
        return False
    digits = [int(d) for d in id_card]
    checksum = sum([digits[i] * (13 - i) for i in range(12)]) % 11
    check_digit = (11 - checksum) % 10
    return check_digit == digits[-1]

def is_valid_enum(val: Any, enum_cls: Type) -> bool:
    """Check if value is a valid member of an Enum class."""
    try:
        return val in [e.value for e in enum_cls]
    except Exception:
        return False

def is_valid_float(val: Any, min_value: Optional[float] = None, max_value: Optional[float] = None) -> bool:
    """Check if value is a valid float and within optional bounds."""
    try:
        f = float(val)
        if min_value is not None and f < min_value:
            return False
        if max_value is not None and f > max_value:
            return False
        return True
    except Exception:
        return False

def is_valid_json(val: Any) -> bool:
    """Check if value is a valid JSON-serializable object."""
    import json
    try:
        json.dumps(val)
        return True
    except Exception:
        return False