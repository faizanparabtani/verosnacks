#!/bin/sh
set -e

# Run migrations
uv run python manage.py migrate --noinput

# Collect static files
uv run python manage.py collectstatic --noinput

# Start server
exec uv run gunicorn -k uvicorn.workers.UvicornWorker --bind "0.0.0.0:8000" verosnacks.asgi:application
