#!/bin/sh
set -e

# Run migrations
echo "Running migrations..."
python manage.py migrate

# Start server
echo "Starting Gunicorn..."
exec gunicorn verosnacks.wsgi:application --bind "0.0.0.0:${PORT:-8000}"
