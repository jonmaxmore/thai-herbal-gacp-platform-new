import os
from functools import lru_cache
from pydantic import BaseSettings, Field, PostgresDsn, validator

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "GACP Herbal AI Backend"
    SECRET_KEY: str = Field(..., env="SECRET_KEY")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    POSTGRES_SERVER: str = Field(..., env="POSTGRES_SERVER")
    POSTGRES_USER: str = Field(..., env="POSTGRES_USER")
    POSTGRES_PASSWORD: str = Field(..., env="POSTGRES_PASSWORD")
    POSTGRES_DB: str = Field(..., env="POSTGRES_DB")
    DATABASE_URL: str = Field(None, env="DATABASE_URL")
    REDIS_URL: str = Field(..., env="REDIS_URL")

    AI_MODELS_PATH: str = Field(default="./ai_models/models")
    STATIC_PATH: str = Field(default="./static")
    LOG_PATH: str = Field(default="./logs")
    ENVIRONMENT: str = Field(default="production")
    DEBUG: bool = Field(default=False)

    @validator("DATABASE_URL", pre=True, always=True)
    def assemble_db_connection(cls, v, values):
        if v and isinstance(v, str):
            return v
        return (
            f"postgresql+asyncpg://{values.get('POSTGRES_USER')}:{values.get('POSTGRES_PASSWORD')}"
            f"@{values.get('POSTGRES_SERVER')}/{values.get('POSTGRES_DB')}"
        )

    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings()