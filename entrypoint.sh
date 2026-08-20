#!/bin/sh
set -e

echo "Running database migrations..."
python manage.py migrate --noinput

echo "Compiling Tailwind CSS..."
python manage.py tailwind build --force

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn verosnacks.wsgi:application \
    --bind "0.0.0.0:8000" \
    --workers ${GUNICORN_WORKERS:-2} \
    --threads ${GUNICORN_THREADS:-4} \
    --worker-class gthread \
    --worker-tmp-dir /dev/shm \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
