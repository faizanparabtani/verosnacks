# Verosnacks

Official site for Vero - A Django-based e-commerce platform for snacks.

## Features

- **E-commerce Functionality:** Product browsing, cart management, and checkout.
- **Payment Processing:** Integrated with Stripe.
- **Media Management:** Cloudinary integration for product images.
- **Modern Frontend:** Styled with Tailwind CSS v4 and DaisyUI.
- **Background Tasks:** Asynchronous processing using Celery and Redis.
- **Containerized:** Full Docker support for development and production.
- **High Performance:** Uses uv for blazing fast Python dependency management.

## Tech Stack

- **Backend:** Python 3.13, Django 6.0
- **Frontend:** HTML5, Tailwind CSS, DaisyUI, JavaScript
- **Database:** PostgreSQL
- **Cache & Broker:** Redis
- **Task Queue:** Celery
- **Package Manager:** uv (Python), npm (Frontend)
- **Infrastructure:** Docker, Docker Compose

## Prerequisites

- Docker and Docker Compose (Recommended)
- uv (For local Python development)
- Node.js 20+ (For local frontend development)

## Installation and Setup

### Option 1: Docker (Recommended)

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd verosnacks
    ```

2.  **Set up environment variables:**
    Create a .env file in the root directory (see [Environment Variables](#environment-variables) below).

3.  **Build and run the containers:**
    ```bash
    docker compose up --build
    ```
    The application will be available at http://localhost:8000.

### Option 2: Local Development

1.  **Install Python dependencies:**
    ```bash
    uv sync
    ```

2.  **Install Frontend dependencies and build CSS:**
    ```bash
    cd frontend/static_src
    npm install
    # Watch mode for development
    npm run dev
    ```

3.  **Run Migrations:**
    ```bash
    uv run python manage.py migrate
    ```

4.  **Start the Development Server:**
    ```bash
    uv run python manage.py runserver
    ```

5.  **Start the Celery Worker (in a separate terminal):**
    ```bash
    uv run celery -a verosnacks worker -l info
    ```

## Environment Variables

Create a .env file in the root directory with the following variables:

```ini
# Django
DEBUG=True
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=postgres://vero_user:vero_password@db:5432/verosnacks

# Redis (Cache & Celery)
REDIS_URL=redis://redis:6379/0

# Cloudinary (Media)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Stripe (Payments)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## Frontend Development

The frontend uses Tailwind CSS v4. Styles are processed from frontend/static_src/src/styles.css and output to frontend/static/css/dist/styles.css.

- **Watch mode:** npm run dev (in frontend/static_src) - Rebuilds CSS on change.
- **Production build:** npm run build - Minifies CSS for production.

## Docker Compose Services

- **web:** Django development server.
- **worker:** Celery worker for background tasks.
- **db:** PostgreSQL 16 database.
- **redis:** Redis 7 for caching and message brokerage.

## Management Commands

- **Create Superuser:**
  ```bash
  # Docker
  docker compose exec web uv run python manage.py createsuperuser

  # Local
  uv run python manage.py createsuperuser
  ```

- **Make Migrations:**
  ```bash
  uv run python manage.py makemigrations
  ```

- **Run Tests:**
  ```bash
  uv run python manage.py test
  ```

## License

This project is licensed under the MIT License.

Copyright (c) 2026 Vero

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.