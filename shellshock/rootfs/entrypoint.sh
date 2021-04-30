#!/bin/sh

# Stop the scrip on any error encountered
set -Eeuo pipefail

# Start a test instance of apache
/usr/sbin/apachectl -k start
sleep 2

# Run a test query
curl -s http://localhost/cgi-bin/hello.cgi -H "X-Name: OpenShift"

# Stop apache
/usr/sbin/apachectl -k stop
sleep 2

# Run the real apache
exec /usr/sbin/httpd -X
