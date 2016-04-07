PYTHON:=$(shell which python)
PIP:=$(shell which pip)

help:
	@echo 'help         - shows this help message'
	@echo 'app          - creates a new application. Usage: make app app=myappname'
	@echo 'db           - resets the database and creates a superuser'
	@echo 'dev          - installs dev requirements and sets up dev environment'
	@echo 'fixtures     - adds fixtures (dummy data) to database'
	@echo 'herokurun    - rule for running environment on heroku'
	@echo 'herokusetup  - sets up environment to work with heroku'
	@echo 'prod         - installs prod requirements and sets up prod environment'
	@echo 'run          - runs the server'
	@echo 'sync         - syncs and migrates the database'
	@echo 'superuser    - creates a superuser'

app:
	cd src/apps; \
	../../$(PYTHON) ../manage.py startapp ${app}
       
db:
	rm src/project.db -f
	#find src/ -type d -name 'migrations' -exec rm -f {} \;
	rm src/app/quiz/migrations -rf
	$(MAKE) sync
	echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'question')" | $(PYTHON) src/manage.py shell

dev:
	echo "from settings.development import *" > src/settings/local.py
	$(PIP) install -r requirements.txt --upgrade

fixtures:
	$(PYTHON) src/manage.py loaddata src/fixtures/demo_data.json
    
herokurun: prod sync fixtures
	echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'question')" | $(PYTHON) src/manage.py shell
	gunicorn src.wsgi:application --pythonpath src --log-file - 

herokusetup:
	wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
    
prod:
	echo "from settings.production import *" > src/settings/local.py
	$(PIP) install -r requirements.txt --upgrade
	$(PYTHON) src/manage.py collectstatic --noinput

run:
	$(PYTHON) src/manage.py runserver $(shell ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}'):8000

sync:
	$(PYTHON) src/manage.py makemigrations quiz
	$(PYTHON) src/manage.py migrate

superuser:
	$(PYTHON) src/manage.py createsuperuser
    
.PHONY: app db dev fixtures herokurun herokusetup prod run sync superuser