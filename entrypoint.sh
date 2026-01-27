#!/bin/sh
set -e

# Run migrations
uv run python manage.py migrate --noinput

# Collect static files
uv run python manage.py collectstatic --noinput

# Start server
exec uv run gunicorn verosnacks.wsgi:application --bind "0.0.0.0:8000" 
