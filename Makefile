help:
	@echo 'help         - shows this help message'
	@echo 'dev          - installs dev requirements and sets up dev environment'
	@echo 'db           - resets the database and creates a superuser'
	@echo 'run          - runs the server'
	@echo 'sync         - syncs and migrates the database'
	@echo 'superuser    - creates a superuser'

dev:
	@echo "from settings.development import *" > src/settings/local.py
	venv/bin/pip install -r requirements/dev.txt --upgrade
    
run:
	venv/bin/python src/manage.py runserver $(shell ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}'):8000

db:
	rm src/project.db -f
	find src/ -type d -name 'migrations' -exec rm -f {} \;
	$(MAKE) sync
	echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'question')" | python src/manage.py shell

app:
	cd src/apps; \
	../../venv/bin/python ../manage.py startapp ${app}

sync:
	venv/bin/python src/manage.py makemigrations quiz
	venv/bin/python src/manage.py migrate

superuser:
	venv/bin/python src/manage.py createsuperuser
    
.PHONY: dev run app superuser sync db