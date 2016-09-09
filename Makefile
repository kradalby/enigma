PYTHON:=$(shell which python)
PIP:=$(shell which pip)

help:
	@echo 'help         - shows this help message'
	@echo 'adminuser    - creates a user with username and password admin/admin'
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

migrate:
	docker-compose run web python manage.py migrate

test:
	docker-compose run web python manage.py test

createsuper:
	docker-compose run web python manage.py createsuperuser

.PHONY: migrate
