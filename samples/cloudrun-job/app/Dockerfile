FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

# python:3.13-slim moved its base OS from Debian 12 (bookworm) to Debian 13
# (trixie) on 2026-11-08 (same tag, new digest) — this pin's zlib1g build
# (1:1.3.dfsg+really1.3.1-1+b1) predates the +deb13u1 security update fixing
# CVE-2026-76844/CVE-2026-85091 (Trivy HIGH). Unpinned on purpose, the base
# digest above stays the anchor — see cloudrun-bastion/app/Dockerfile for the
# same pattern.
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=True

WORKDIR /app

COPY job.py .

# job.py is stdlib-only: drop pip, whose vendored msgpack/setuptools/urllib3
# carry open HIGH CVEs (Trivy) and are never used at runtime.
RUN python -m pip uninstall -y pip

RUN useradd -r -u 1000 appuser
USER appuser

CMD ["python", "job.py"]
