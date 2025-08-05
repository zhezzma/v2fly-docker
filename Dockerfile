FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

WORKDIR /tmp
ARG WORKDIR=/tmp
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh "${WORKDIR}"/v2ray.sh
COPY config.json /tmp/config.json.template

RUN set -ex \
    && apk add --no-cache ca-certificates gettext \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"

# 修改 ENTRYPOINT，分步执行并添加调试信息
# 启动脚本
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo '=== 调试信息 ==='; \
     cat /tmp/config.json.template; \
     echo '=== 开始处理 ==='; \
     if [ -z \"$UUID\" ]; then \
         echo '错误: UUID环境变量未设置'; \
         exit 1; \
     fi; \
     echo \"使用UUID: $UUID\"; \
     sed \"s/env:UUID/$UUID/g\" /tmp/config.json.template > /tmp/config.json; \
     echo '=== 生成的配置文件 ==='; \
     cat /tmp/config.json; \
     echo '=== 启动V2Ray ==='; \
     exec /usr/bin/v2ray run -config /tmp/config.json"]
