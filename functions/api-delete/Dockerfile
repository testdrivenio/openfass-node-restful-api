FROM alpine:3.7

RUN apk --update add nodejs nodejs-npm

ADD https://github.com/openfaas/faas/releases/download/0.7.9/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root/

COPY package.json .

RUN npm i
COPY handler.js .

ENV fprocess="node handler.js"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
