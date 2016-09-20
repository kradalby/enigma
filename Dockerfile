FROM python:3.5.2
MAINTAINER kradalby@kradalby.no
EXPOSE 8000

ENV APP_DIR=/srv/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY requirements/base.txt $APP_DIR/base.txt
COPY requirements/dev.txt $APP_DIR/dev.txt

RUN apt-get update && \
    apt-get install graphviz -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install -r $APP_DIR/dev.txt

ENV DJANGO_SETTINGS_MODULE settings.development

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
