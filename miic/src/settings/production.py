DEBUG = False

DATABASES = {
    'default': {
        # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        # Or path to database file if using sqlite3.
        'NAME': 'medimgquiz',
        # Not used with sqlite3.
        'USER': 'medimgquizuser',
        # Not used with sqlite3.
        'PASSWORD': 'medimgquiz',
        # Set to empty string for localhost. Not used with sqlite3.
        'HOST': 'localhost',
        # Set to empty string for default. Not used with sqlite3.
        'PORT': '',
    }
}

# import dj_database_url
# db_from_env = dj_database_url.config(conn_max_age=500)
# print(db_from_env)
# DATABASES['default'].update(db_from_env)

# from settings.base import *
# import os

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': os.path.join(BASE_DIR, 'project.db')
#     }
# }

STATICFILES_STORAGE = 'whitenoise.django.GzipManifestStaticFilesStorage'
