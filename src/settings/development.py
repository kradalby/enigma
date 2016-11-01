from settings.base import *

DEBUG = True

SECRET_KEY = "dev"


def custom_show_toolbar(request):
    return DEBUG


INSTALLED_APPS += ('debug_toolbar', 'django_extensions')

DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': custom_show_toolbar,
    'HIDE_DJANGO_SQL': False,
    # Set to True if you want to see requests before you are redirected
    'INTERCEPT_REDIRECTS': False,
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'postgres',
        'USER': 'postgres',
        'HOST': 'db',
        'PORT': 5432,
    }
}

MIDDLEWARE_CLASSES += ('debug_toolbar.middleware.DebugToolbarMiddleware',)
