FROM alpine:3.6

WORKDIR /app

RUN apk update
RUN apk add taskd

ENV TASKDDATA /var/taskd
VOLUME $TASKDDATA

CMD taskd server
