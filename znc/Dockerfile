FROM alpine:3.6

WORKDIR /app

RUN apk update
RUN apk add znc
RUN apk add ca-certificates

RUN adduser app -D -u 1001
USER app

VOLUME /home/app

CMD znc --foreground
