#!/bin/sh
set -e

# Run migrations
echo "Running migrations..."
uv run python manage.py migrate --noinput

# Start server
echo "Starting Gunicorn..."
exec uv run gunicorn verosnacks.wsgi:application --bind "0.0.0.0:${PORT:-8000}"
