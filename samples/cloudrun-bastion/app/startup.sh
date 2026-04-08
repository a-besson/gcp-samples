#!/bin/sh
set -e

echo "Starting Tinyproxy (HTTP Bastion) on port 8080..."
# -d runs tinyproxy in the foreground/debug mode (logs to stdout)
exec /usr/bin/tinyproxy -d -c /etc/tinyproxy/tinyproxy.conf
