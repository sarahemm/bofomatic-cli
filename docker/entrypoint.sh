#!/bin/sh
# PID 1 (under tini): run the telnet daemon and, if a serial device is mapped
# in, a respawning getty on it. Both funnel through /bin/login -> the `bof`
# account -> /usr/local/bin/bofomatic-shell -> the CLI.
set -u

TELNET_PORT="${TELNET_PORT:-23}"

echo ">> telnetd listening on port ${TELNET_PORT} (login: bof)"
telnetd -F -p "${TELNET_PORT}" -l /bin/login &
TELNET_PID=$!

# Serial console for a physical terminal (e.g. a VT320). SERIAL_DEV is the
# device path *inside* the container, mapped from the host via compose.
if [ -n "${SERIAL_DEV:-}" ] && [ -e "${SERIAL_DEV:-}" ]; then
  BAUD="${SERIAL_BAUD:-9600}"
  TERMTYPE="${SERIAL_TERM:-vt320}"
  TTY_NAME="${SERIAL_DEV#/dev/}"   # agetty wants the name, not the full path
  echo ">> getty on ${SERIAL_DEV} @ ${BAUD} 8N1, TERM=${TERMTYPE}"
  while true; do
    agetty -L "${BAUD}" "${TTY_NAME}" "${TERMTYPE}" || true
    sleep 1   # respawn after the session ends / on error
  done
else
  if [ -n "${SERIAL_DEV:-}" ]; then
    echo ">> SERIAL_DEV=${SERIAL_DEV} not present in container; serial disabled."
  fi
  wait "${TELNET_PID}"
fi
