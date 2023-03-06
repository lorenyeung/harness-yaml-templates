FROM alpine:latest

RUN apk update \
 && apk add --no-cache curl jq bash yq --upgrade grep \
 && rm -rf /var/cache/apk/*
