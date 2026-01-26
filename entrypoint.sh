#!/bin/sh
set -e

# Run migrations
uv run python manage.py migrate --noinput

# Start server
uv run gunicorn -k uvicorn.workers.UvicornWorker --bind "0.0.0.0:${PORT:-8000}" verosnacks.wsgi:application
