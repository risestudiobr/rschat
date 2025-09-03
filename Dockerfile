FROM chatwoot/chatwoot:latest

RUN apk add --no-cache multirun postgresql-client

WORKDIR /app

COPY . /app

COPY --chmod=755 start-web.sh /usr/local/bin/start.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/usr/local/bin/start.sh"]
