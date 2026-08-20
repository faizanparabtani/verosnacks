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

# Download and install tailwindcss CLI binary
RUN curl -sL https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.3/tailwindcss-linux-x64 -o /usr/local/bin/tailwindcss && \
    chmod +x /usr/local/bin/tailwindcss

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Install Python dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# Copy project files
COPY . .

# Install the project itself
RUN uv sync --frozen --no-dev

RUN useradd -m -u 1000 django && \
    chown -R django:django /code
USER django

# Expose port
EXPOSE 8000

# Copy entrypoint script and make it executable
COPY --chmod=755 entrypoint.sh /code/entrypoint.sh
# Run the entrypoint script
CMD ["/code/entrypoint.sh"]