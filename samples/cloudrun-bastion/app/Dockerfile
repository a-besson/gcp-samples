FROM alpine:3.21

# Install Dante SOCKS5 server
RUN apk add --no-cache dante-server=1.4.3-r4

COPY sockd.conf /etc/sockd.conf

EXPOSE 8080

CMD ["sockd", "-f", "/etc/sockd.conf"]
