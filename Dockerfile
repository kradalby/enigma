FROM node:7.6.0

MAINTAINER Kristoffer Dalby <kradalby@kradalby.no>

ENV TMPDIR /tmp/

RUN npm install -g elm@0.18.0
RUN npm install -g elm-test@0.18.0

ENTRYPOINT ["elm"]
