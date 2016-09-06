from settings.base import *
import os

DEBUG = True

SECRET_KEY = "dev"

def custom_show_toolbar(request):
    return DEBUG

INSTALLED_APPS += (
    'debug_toolbar',
)

DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': custom_show_toolbar,
    'HIDE_DJANGO_SQL': False,
    'INTERCEPT_REDIRECTS': False,  # Set to True if you want to see requests before you are redirected
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'postgres',
        'USER': 'postgres',
        'HOST': 'db',
        'PORT': 5432,
    }
}

MIDDLEWARE_CLASSES += (
    'debug_toolbar.middleware.DebugToolbarMiddleware',
)

TEMPLATES[0]['OPTIONS']['context_processors'] += (
   'django.core.context_processors.debug',
)

