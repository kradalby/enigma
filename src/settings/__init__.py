from settings.base import *

try:
    from settings.local import *
except ImportError:
    print ("""
          Could not import local settings, if you want to set up
          local settings for dev run this:
          $ make dev
          or
          $ make prod
          
          For now, we import development settings, because Heroku is misbehaving.
          """)
    #raise ImportError
    from settings.development import *