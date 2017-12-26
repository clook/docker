FROM multiarch/alpine:amd64-v3.6

RUN echo 'syncthing:x:1000:1000::/var/syncthing:/sbin/nologin' >> /etc/passwd \
    && echo 'syncthing:!::0:::::' >> /etc/shadow \
    && mkdir /var/syncthing \
    && chown syncthing /var/syncthing

RUN apk add --no-cache curl jq gnupg \
    && gpg --keyserver keyserver.ubuntu.com --recv-key D26E6ED000654A3E

ENV release=
ENV arch=

RUN set -x \
    && mkdir /syncthing \
    && cd /syncthing \
    && release=${release:-$(curl -s https://api.github.com/repos/syncthing/syncthing/releases/latest | jq -r .tag_name )} \
    && arch=${arch:-amd64} \
    && curl -sLO https://github.com/syncthing/syncthing/releases/download/${release}/syncthing-linux-${arch}-${release}.tar.gz \
    && curl -sLO https://github.com/syncthing/syncthing/releases/download/${release}/sha256sum.txt.asc \
    && gpg --verify sha256sum.txt.asc \
    && grep syncthing-linux-${arch} sha256sum.txt.asc | sha256sum \
    && tar -zxf syncthing-linux-${arch}-${release}.tar.gz \
    && mv syncthing-linux-${arch}-${release}/syncthing . \
    && rm -rf syncthing-linux-${arch}-${release} sha256sum.txt.asc syncthing-linux-${arch}-${release}.tar.gz \
    && apk del gnupg jq curl

USER syncthing
ENV STNOUPGRADE=1

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 22000 || exit 1

ENTRYPOINT ["/syncthing/syncthing", "-home", "/var/syncthing/config", "-gui-address", "0.0.0.0:8384"]
