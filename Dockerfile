FROM alpine:latest

RUN apk add --no-cache \
    curl \
    bash \
    ca-certificates \
    socat \
    tzdata \
    sqlite \
    nginx \
    gettext \
    tor \
    jq \
    openssl \
    coreutils \
    dos2unix \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# ---- 3x-ui panel binary -----------------------------------------------------
RUN curl -L https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz \
    && tar -xzf /tmp/x-ui.tar.gz -C /usr/local/ \
    && rm /tmp/x-ui.tar.gz \
    && chmod +x /usr/local/x-ui/x-ui

# ---- Runtime directories -----------------------------------------------------
RUN mkdir -p \
    /etc/x-ui \
    /var/log/x-ui \
    /var/log/tor \
    /var/www/tor-status \
    /etc/tor/instances \
    /var/lib/tor-instances

# ---- Application files -------------------------------------------------------
COPY config.json /etc/x-ui/config.json
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
COPY panel-bootstrap.sh /panel-bootstrap.sh

# Fix Windows line endings and set execute permissions
RUN dos2unix /start.sh /panel-bootstrap.sh \
    && chmod +x /start.sh /panel-bootstrap.sh

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=5 \
    CMD curl -fsS "http://127.0.0.1:3000/health" || exit 1

CMD ["/start.sh"]
