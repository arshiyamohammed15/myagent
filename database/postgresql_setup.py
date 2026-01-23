from __future__ import annotations

import os
from typing import Generator, Optional

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Declarative base for ORM models
Base = declarative_base()


def build_postgres_url(
    user: Optional[str] = None,
    password: Optional[str] = None,
    host: Optional[str] = None,
    port: Optional[str] = None,
    database: Optional[str] = None,
    ssl_mode: Optional[str] = None,
) -> str:
    """
    Build a PostgreSQL connection URL from explicit params or environment variables.

    Env vars used (fallback order):
      POSTGRES_USER
      POSTGRES_PASSWORD
      POSTGRES_HOST (default: localhost)
      POSTGRES_PORT (default: 5432)
      POSTGRES_DB   (default: planner)
      POSTGRES_SSL_MODE (optional, e.g., require)
    """
    user = user or os.environ.get("POSTGRES_USER", "postgres")
    password = password or os.environ.get("POSTGRES_PASSWORD", "postgres")
    host = host or os.environ.get("POSTGRES_HOST", "localhost")
    port = port or os.environ.get("POSTGRES_PORT", "5432")
    database = database or os.environ.get("POSTGRES_DB", "planner")
    ssl_mode = ssl_mode or os.environ.get("POSTGRES_SSL_MODE")

    # URL-encode password to handle special characters like @, :, /, etc.
    from urllib.parse import quote_plus
    if password:
        encoded_password = quote_plus(password)
        auth_part = f"{user}:{encoded_password}@"
    else:
        auth_part = f"{user}@"
    params = f"?sslmode={ssl_mode}" if ssl_mode else ""
    return f"postgresql+psycopg2://{auth_part}{host}:{port}/{database}{params}"


def get_engine(url: Optional[str] = None) -> Engine:
    """
    Create a SQLAlchemy engine for PostgreSQL.

    Env vars:
      DATABASE_URL (takes precedence if set)
      APP_ENV (if 'test', sets echo=False regardless of env)
      SQLALCHEMY_ECHO (truthy to enable SQL echo)
    """
    db_url = url or os.environ.get("DATABASE_URL") or build_postgres_url()
    app_env = os.environ.get("APP_ENV", "").lower()
    echo_env = os.environ.get("SQLALCHEMY_ECHO", "").lower()
    echo = False if app_env == "test" else echo_env in {"1", "true", "yes", "on"}

    return create_engine(
        db_url,
        pool_pre_ping=True,
        future=True,
        echo=echo,
    )


def get_sessionmaker(engine: Optional[Engine] = None) -> sessionmaker:
    engine = engine or get_engine()
    return sessionmaker(bind=engine, autocommit=False, autoflush=False, future=True)


def get_session(engine: Optional[Engine] = None) -> Generator:
    """
    Yield a database session, ensuring proper close/rollback.
    Suitable for FastAPI dependency usage.
    """
    SessionLocal = get_sessionmaker(engine)
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


__all__ = [
    "Base",
    "build_postgres_url",
    "get_engine",
    "get_sessionmaker",
    "get_session",
]

