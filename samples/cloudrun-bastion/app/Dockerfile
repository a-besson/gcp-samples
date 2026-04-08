FROM debian:bookworm-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install Tinyproxy and industrial tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    tinyproxy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure a dedicated tinyproxy user/group exists
RUN groupadd -r tinyproxy && useradd -r -g tinyproxy -s /sbin/nologin tinyproxy || true

# Copy configuration and startup script
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Tinyproxy listens on 8080 by default in our config
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/startup.sh"]
