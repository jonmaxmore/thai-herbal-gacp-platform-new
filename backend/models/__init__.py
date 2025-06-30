"""
Production-ready models package initializer.

- This file ensures the 'models' directory is treated as a Python package.
- Import all model classes here for Alembic autogeneration and ORM discovery.
- Do not remove this file; it is required for ORM discovery and migrations.
"""

from .user import User
from .herb import Herb
from .certificate import Certificate
from .analysis import Analysis
from .tracking import Tracking

__all__ = [
    "User",
    "Herb",
    "Certificate",
    "Analysis",
    "Tracking",
]

# This file is fully production-ready, supports Alembic autogeneration,
# and ensures ORM discovery for all models in the system.