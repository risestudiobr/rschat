FROM chatwoot/chatwoot:latest

RUN apk add --no-cache multirun postgresql-client

WORKDIR /app

COPY . /app

COPY --chmod=755 start.sh ./

ENTRYPOINT ["/bin/sh"]
CMD ["./start.sh"]
