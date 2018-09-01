FROM node:10 as elmbuilder
WORKDIR /app

RUN yarn global add elm@0.18.0

ADD enigma/package.json .
RUN npm install

ADD enigma/elm-package.json .
RUN elm package install -y

ADD enigma .

RUN npm run build

FROM python:3.7.0 as production
MAINTAINER kradalby@kradalby.no

ENV APP_DIR=/srv/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY miic/requirements/base.txt $APP_DIR/base.txt
COPY miic/requirements/prod.txt $APP_DIR/prod.txt

RUN pip install -r $APP_DIR/prod.txt


COPY miic/src/. $APP_DIR
RUN mkdir -p $APP_DIR/enigma_app
COPY --from=elmbuilder /app/dist/. $APP_DIR/enigma_app

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV DJANGO_SETTINGS_MODULE=settings.base
RUN python manage.py collectstatic --noinput --clear
ENV DJANGO_SETTINGS_MODULE=settings.production

EXPOSE 8080
EXPOSE 8081


CMD ["sh", "/docker-entrypoint.sh"]
