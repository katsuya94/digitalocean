FROM alpine:3.6

WORKDIR /app

RUN apk update
RUN apk add znc

RUN adduser admin -D
USER admin

CMD znc --foreground
