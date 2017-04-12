FROM python:3.6.1
MAINTAINER kradalby@kradalby.no

ENV APP_DIR=/srv/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY requirements/base.txt $APP_DIR/base.txt
COPY requirements/dev.txt $APP_DIR/dev.txt

RUN pip install -r $APP_DIR/dev.txt


EXPOSE 8080

WORKDIR $APP_DIR/src
CMD ["python", "manage.py", "runserver", "0.0.0.0:8080"]
