ENV=./env/bin
SHELL := /bin/bash
PYTHON=$(ENV)/python
PIP=$(ENV)/pip
MANAGE=$(PYTHON) manage.py

collect_static:
	$(MANAGE) collectstatic --noinput --clear --link

flake8:
	$(ENV)/flake8 ./src

dev:
	$(PIP) install -r requirements/dev.txt --upgrade

prod:
	$(PIP) install -r requirements/prod.txt --upgrade

init:
	tar xJvf media.tar.xz --directory src/
	tar xJvf postgres.tar.xz --directory src/

env:
	virtualenv -p `which python3` env

clean:
		pyclean .
		find . -name "*.pyc" -exec rm -rf {} \;
		rm -rf *.egg-info

test:
	$(MANAGE) test

run:
	$(MANAGE) runserver 0.0.0.0:8000

freeze:
	mkdir -p requirements
	$(PIP) freeze > requirements/base.txt

createsuperuser:
	docker-compose run --entrypoint="bash -c" turbo "./manage.py createsuperuser"

loaddata:
	docker-compose run --entrypoint="bash -c" turbo "./manage.py loaddata 200916.json"

migrate:
	docker-compose run --entrypoint="bash -c" turbo "./manage.py migrate"

makemigrations:
	docker-compose run --entrypoint="bash -c" turbo "./manage.py makemigrations ${ARGS}"
