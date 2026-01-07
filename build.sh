#!/usr/bin/env bash
set -o errexit

# Ensure uv is available
if ! command -v uv &> /dev/null; then
    echo "uv not found, installing..."
    pip install uv
fi

# Install dependencies with uv
echo "Syncing dependencies with uv..."
uv sync --frozen --no-dev

# Build Tailwind
echo "Building frontend..."
cd frontend/static_src
npm install
npm run build
cd ../..

# Collect static files
echo "Collecting static files..."
uv run python manage.py collectstatic --no-input
