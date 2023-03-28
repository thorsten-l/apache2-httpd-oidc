docker build \
    --build-arg HTTPD_VERSION=2.4.56 \
    --build-arg MOD_VERSION=2.4.13.1 \
    -t apache2-httpd-oidc:latest .
