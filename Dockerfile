ARG HTTPD_VERSION
FROM httpd:${HTTPD_VERSION}-bullseye as builder

ARG MOD_VERSION

RUN mkdir /work && apt update -y && \
  apt install -y wget libcjose0 libhiredis0.14 apache2-bin \
  pkg-config libcurl3-dev openssl libssl-dev libjansson-dev \
  libcjose-dev libhiredis-dev build-essential apache2-dev

RUN cd /work \
  && wget https://github.com/OpenIDC/mod_auth_openidc/releases/download/v${MOD_VERSION}/mod_auth_openidc-${MOD_VERSION}.tar.gz -O mod_auth_openidc.tar.gz \
  && tar xvfz mod_auth_openidc.tar.gz && mv mod_auth_openidc-* mod_auth_openidc

RUN cd /work/mod_auth_openidc && ./configure && make && make install

ARG HTTPD_VERSION
FROM httpd:${HTTPD_VERSION}-bullseye

ARG HTTPD_VERSION

LABEL description="Apache2 HTTPd + OIDC auth module (OpenID Connect)"
LABEL maintainer="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL version=${HTTPD_VERSION}
LABEL org.opencontainers.image.authors="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/thorsten-l/apache2-httpd-oidc"
LABEL org.opencontainers.image.documentation="https://github.com/thorsten-l/apache2-httpd-oidc"
LABEL org.opencontainers.image.description="Apache2 HTTPd + OIDC auth module (OpenID Connect)"
LABEL org.opencontainers.image.license="Apache-2.0"
LABEL org.opencontainers.image.version=${HTTPD_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /usr/local/apache2/modules/mod_auth_openidc.so /usr/local/apache2/modules/mod_auth_openidc.so
COPY --from=builder /usr/local/apache2/modules/mod_auth_openidc.so /usr/lib/apache2/modules/mod_auth_openidc.so

RUN apt update -y \
  && apt install -y libcjose0 libhiredis0.14 apache2-bin \
  && chmod 0755 /entrypoint.sh \
  && mkdir /usr/local/apache2/dist \ 
  && mv /usr/local/apache2/cgi-bin /usr/local/apache2/conf /usr/local/apache2/htdocs /usr/local/apache2/dist

EXPOSE 80 443
VOLUME /usr/local/apache2/cgi-bin /usr/local/apache2/conf /usr/local/apache2/htdocs /usr/local/apache2/logs 
WORKDIR /usr/local/apache2

ENTRYPOINT [ "/entrypoint.sh" ]
