# syntax=docker/dockerfile:1
FROM alpine:3.20

# Password for the `bof` login account (telnet + serial). Override at build:
#   docker build --build-arg BOF_PASSWORD=hunter2 .
ARG BOF_PASSWORD=hunter2

RUN apk add --no-cache \
      ruby ruby-dev build-base \
      ncurses ncurses-dev ncurses-terminfo \
      busybox-extras agetty shadow \
      tini tzdata

RUN gem install --no-document curses fstui ruby-bofomatic

# ---- Application -------------------------------------------------------------
WORKDIR /opt/bofomatic
COPY bofomatic-cli ./bofomatic-cli
# Baked-in default config; override by bind-mounting your own (see compose).
COPY bofomatic-cli.yaml.example ./bofomatic-cli.yaml
RUN chmod +x ./bofomatic-cli

# ---- Login plumbing ----------------------------------------------------------
COPY docker/bofomatic-shell /usr/local/bin/bofomatic-shell
COPY docker/entrypoint.sh   /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/bofomatic-shell /usr/local/bin/entrypoint.sh

# The `bof` account whose LOGIN SHELL *is* the CLI.
RUN adduser -D -h /home/bof -s /usr/local/bin/bofomatic-shell bof \
 && echo "bof:${BOF_PASSWORD}" | chpasswd \
 && echo /usr/local/bin/bofomatic-shell >> /etc/shells

EXPOSE 23
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
