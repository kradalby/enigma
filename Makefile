ENV=./env/bin
SHELL := /bin/bash
PYTHON=$(ENV)/python
PIP=$(ENV)/pip
MANAGE=$(PYTHON) manage.py

collect_static:
	$(MANAGE) collectstatic --noinput --clear --link

flake8:
	$(ENV)/flake8 ./src

migrate:
	$(MANAGE) migrate

dev:
	$(PIP) install -r requirements/dev.txt --upgrade

prod:
	$(PIP) install -r requirements/prod.txt --upgrade

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
