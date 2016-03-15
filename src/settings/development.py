from settings.base import INSTALLED_APPS, MIDDLEWARE_CLASSES, TEMPLATES, BASE_DIR
import os

DEBUG = True

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
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'project.db')
    }
}

MIDDLEWARE_CLASSES += (
    'debug_toolbar.middleware.DebugToolbarMiddleware',
)

TEMPLATES[0]['OPTIONS']['context_processors'] += (
   'django.core.context_processors.debug',
)