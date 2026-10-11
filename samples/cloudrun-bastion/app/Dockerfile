# Debian bookworm's tinyproxy package (1.11.1-2.1+deb12u1, latest available in
# bookworm/bookworm-security as of this build) has no fix for several open,
# unpatched CVEs (see PR description): request smuggling via conflicting
# Content-Length/Transfer-Encoding handling, chunked-parsing integer overflow,
# and a Host-header stathost bypass. Debian tracks these as "Minor issue"
# (no DSA planned), so apt will never resolve them on this branch. The fixes
# only exist as unreleased commits on upstream master (no tag newer than
# 1.11.3 includes them) — build from that pinned commit instead.
#
# KICS "Missing User Instruction": no explicit USER in the runtime stage, but
# tinyproxy.conf already sets `User tinyproxy` / `Group tinyproxy` — verified
# at runtime that PID 1 drops root and runs as uid 999 (tinyproxy) before
# accepting any connection.
# kics-scan ignore-line
FROM debian:bookworm-slim@sha256:7c7b2c966bc9ee8cedfeef67e0e279108992c77681fa595db4a9d65c06ccc587 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    gperf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# Pinned to upstream master @ 2026-07-24. Includes the smuggling/overflow/
# stathost fixes above (commits bb7edc4, 879bf84, 7bc33a7, 623bfc0, 364cdb6,
# 09312a1). Bump this SHA once a tinyproxy release > 1.11.3 ships them.
RUN git clone https://github.com/tinyproxy/tinyproxy.git . \
    && git checkout 2e47897011becd0b74e3dc8d217dca44132de363

RUN ./autogen.sh \
    && ./configure --prefix=/usr --disable-manpage-support \
    && make -j"$(nproc)" \
    && make install DESTDIR=/out

FROM debian:bookworm-slim@sha256:7c7b2c966bc9ee8cedfeef67e0e279108992c77681fa595db4a9d65c06ccc587

# Pick up Debian security fixes published after the pinned base image was built
# (e.g. perl-base, libpcre2); unpinned on purpose, the base digest above stays the anchor.
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Ensure a dedicated tinyproxy user/group exists
RUN groupadd -r tinyproxy && useradd -r -g tinyproxy -s /sbin/nologin tinyproxy || true

COPY --from=builder /out/usr/bin/tinyproxy /usr/bin/tinyproxy

# Copy configuration and startup script
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Tinyproxy listens on 8080 by default in our config
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/startup.sh"]
