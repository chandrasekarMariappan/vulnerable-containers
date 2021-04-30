#!/bin/sh

echo "Content-Type: text/plain"
echo
echo "Hello, ${HTTP_X_NAME:-World}!"
