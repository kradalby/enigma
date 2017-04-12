FROM python:3.6.1
MAINTAINER kradalby@kradalby.no

ENV APP_DIR=/srv/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY requirements/base.txt $APP_DIR/base.txt
COPY requirements/prod.txt $APP_DIR/prod.txt
COPY lol.txt $APP_DIR/lol.txt

RUN pip install -r $APP_DIR/prod.txt


COPY src/. $APP_DIR

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV DJANGO_SETTINGS_MODULE=settings.base
RUN python manage.py collectstatic --noinput --clear
ENV DJANGO_SETTINGS_MODULE=settings.production

EXPOSE 8080
EXPOSE 8081


CMD ["sh", "/docker-entrypoint.sh"]
