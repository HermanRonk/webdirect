#!/bin/bash

# Check if REDIRECT_TARGET is set
if [ -z "$REDIRECT_TARGET" ]; then
    echo "Redirect target variable not set (REDIRECT_TARGET)"
    exit 1
else
    # Add https if not set
    if ! [[ $REDIRECT_TARGET =~ ^http?:// ]]; then
        REDIRECT_TARGET="https://$REDIRECT_TARGET"
    fi

    # Add trailing slash
    if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
        REDIRECT_TARGET="$REDIRECT_TARGET/"
    fi
fi

# Default to 80, Traefik will handle HTTPS
LISTEN="80"

# Use PORT variable if given
if [ ! -z "$PORT" ]; then
    LISTEN="$PORT"
fi

# Create Nginx config
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen ${LISTEN};
    rewrite ^/(.*)\$ ${REDIRECT_TARGET}\$1 permanent;
}
EOF

echo "Listening to $LISTEN, Redirecting HTTP requests to ${REDIRECT_TARGET}..."

# Start Nginx
exec nginx -g "daemon off;"
