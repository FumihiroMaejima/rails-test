# FROM ruby:2.6.5-alpine3.11
FROM ruby:3.2.2-alpine3.18

ENV WORKDIR="/var/www/html"
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

WORKDIR ${WORKDIR}

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        gcc \
        g++ \
        libc-dev \
        libxml2-dev \
        linux-headers \
        make \
        nodejs \
        gcompat \
        mysql-client \
        mysql-dev \
        # postgresql \
        # postgresql-dev \
        tzdata \
        yarn && \
    apk add --virtual build-packs --no-cache \
        build-base \
        curl-dev

COPY ./backend/Gemfile ${WORKDIR}
COPY ./backend/Gemfile.lock ${WORKDIR}

RUN bundle install
RUN apk del build-packs

COPY ./backend ${WORKDIR}

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
