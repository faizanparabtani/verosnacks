import os
from celery import Celery

# Check for the Railway environment variable
if os.environ.get("RAILWAY_PUBLIC_DOMAIN"):
    settings_module = "verosnacks.deployment_settings"
else:
    settings_module = "verosnacks.settings"

os.environ.setdefault("DJANGO_SETTINGS_MODULE", settings_module)

app = Celery("verosnacks")

app.config_from_object("django.conf:settings", namespace="CELERY")

app.autodiscover_tasks()


@app.task(bind=True)
def debug_task(self):
    print(f"Request: {self.request!r}")
