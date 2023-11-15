#!/bin/bash

# Check if REDIRECT_TARGET is set and valid
if [ -z "$REDIRECT_TARGET" ]; then
    echo "Error: Redirect target variable not set (REDIRECT_TARGET)"
    exit 1
elif ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
    echo "Error: REDIRECT_TARGET is not a valid URL"
    exit 1
fi

# Ensure REDIRECT_TARGET ends with a slash
if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
    REDIRECT_TARGET="$REDIRECT_TARGET/"
fi

echo "Redirect target is set to ${REDIRECT_TARGET}"

# Default to 80, overridden by PORT variable if set
LISTEN="${PORT:-80}"

echo "Nginx will listen on port ${LISTEN}"

# Create Nginx config
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen ${LISTEN};
    rewrite ^/(.*)\$ ${REDIRECT_TARGET}\$1 permanent;
}
EOF

echo "Nginx configuration file has been created"

echo "Starting Nginx, listening on port ${LISTEN}, redirecting requests to ${REDIRECT_TARGET}..."
exec nginx -g "daemon off;"
