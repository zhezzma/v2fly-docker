FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

WORKDIR /tmp
ARG WORKDIR=/tmp
ARG TARGETPLATFORM
ARG TAG

COPY v2ray.sh "${WORKDIR}"/v2ray.sh

RUN set -ex \
    && apk add --no-cache ca-certificates gettext \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"


# 要放在后面.v2ray.sh脚本可能删除/tmp目录的内容
COPY config.json /tmp/config.json.template

# 修改 ENTRYPOINT，分步执行并添加调试信息,开始启动脚本
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sed \"s/env:UUID/$UUID/g\" /tmp/config.json.template > /tmp/config.json; \
     exec /usr/bin/v2ray run -config /tmp/config.json"]
