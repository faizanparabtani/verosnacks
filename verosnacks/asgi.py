import os

from django.core.asgi import get_asgi_application

# If RAILWAY_PUBLIC_DOMAIN exists, we are in PROD
if os.environ.get("RAILWAY_PUBLIC_DOMAIN"):
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "verosnacks.deployment_settings")
else:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "verosnacks.settings")

application = get_asgi_application()
