FROM node:18-alpine3.17

RUN apk update &&\
    apk del openssl &&\
    apk add --virtual build-dependencies wget make build-base gcc git perl linux-headers &&\
    wget https://www.openssl.org/source/openssl-3.1.4.tar.gz &&\
    tar -xzvf openssl-3.1.4.tar.gz &&\
    cd openssl-3.1.4 &&\
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl fips &&\
    make &&\
    make install

# fix vulns in libcrypto3 and libssl3
RUN apk update &&\
    apk upgrade &&\
    apk add libcrypto3=3.0.12-r1 libssl3=3.0.12-r1

ENV PATH "/usr/local/ssl/bin:${PATH}"
RUN openssl fipsinstall -out /usr/local/ssl/fipsmodule.cnf -module /usr/local/ssl/lib64/ossl-modules/fips.so -provider_name fips

COPY nodejs.cnf /usr/local/nodejs.cnf

ENV OPENSSL_CONF /usr/local/nodejs.cnf
ENV OPENSSL_MODULES /usr/local/ssl/lib64/ossl-modules

RUN apk del build-dependencies && \
    rm -rf openssl-3.1.4.tar.gz openssl-3.1.4
