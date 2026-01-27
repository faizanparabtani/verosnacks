# Stage 1: Build Frontend
FROM node:20-slim AS frontend-builder
WORKDIR /app

# Copy the source and templates (needed for Tailwind class scanning)
COPY frontend/static_src ./frontend/static_src
COPY frontend/templates ./frontend/templates

# Create the output directory structure
RUN mkdir -p frontend/static/css/dist

WORKDIR /app/frontend/static_src
RUN npm install
RUN npm run build

# Stage 2: Python Runtime
FROM python:3.13-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_PROJECT_ENVIRONMENT=/venv \
    UV_PYTHON_DOWNLOADS=auto \
    PATH="/venv/bin:$PATH"

WORKDIR /code

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Install Python dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# Copy project files
COPY . .

# Install the project itself
RUN uv sync --frozen --no-dev

# Copy built frontend assets from builder
COPY --from=frontend-builder /app/frontend/static/css/dist/styles.css /code/frontend/static/css/dist/styles.css

# Expose port
EXPOSE 8000

# Copy entrypoint script and make it executable
COPY entrypoint.sh /code/entrypoint.sh
RUN chmod +x /code/entrypoint.sh

# Run the entrypoint script
CMD ["/code/entrypoint.sh"]
