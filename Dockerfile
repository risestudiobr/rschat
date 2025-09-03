FROM chatwoot/chatwoot:latest

RUN apk add --no-cache multirun postgresql-client

WORKDIR /app

COPY . /app

RUN bundle config set without 'development test' && \
    bundle install -j4 --retry 3 && \
    if [ -f package.json ]; then \
      yarn install --frozen-lockfile || yarn install; \
    fi

COPY --chmod=755 start-web.sh /usr/local/bin/start.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/usr/local/bin/start.sh"]
