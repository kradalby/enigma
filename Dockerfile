FROM node:7.6.0

MAINTAINER Kristoffer Dalby <kradalby@kradalby.no>

RUN npm install -g elm@0.18.0
RUN npm install -g elm-test@0.18.0

ENTRYPOINT ["elm"]
