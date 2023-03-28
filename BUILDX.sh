#!/bin/bash

HTTPD_VERSION=$1
MOD_VERSION=$2
echo "HTTPD_VERSION=$HTTPD_VERSION"
echo "MOD_VERSION=$MOD_VERSION"
shift
shift

TAGS=""

while (( $# )); do
  TAGS="$TAGS --tag ghcr.io/thorsten-l/apache2-httpd-oidc:$1"
  shift
done

BUILDING_TAGS=$(echo $TAGS | tr ' ' "\n")

docker buildx build --no-cache \
  --build-arg HTTPD_VERSION="$HTTPD_VERSION" \
  --build-arg MOD_VERSION="$MOD_VERSION" \
  --push \
  --platform linux/arm64,linux/amd64 $BUILDING_TAGS .
