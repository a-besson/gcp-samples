FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

# Pick up Debian security fixes published after the pinned base image was built
# (e.g. zlib1g, CVE-2026-76844/CVE-2026-85091 — fixed in trixie-security but not
# yet baked into this tag); unpinned on purpose, the base digest above stays the anchor.
RUN apt-get update && apt-get upgrade -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=True

WORKDIR /app

COPY job.py .

# job.py is stdlib-only: drop pip, whose vendored msgpack/setuptools/urllib3
# carry open HIGH CVEs (Trivy) and are never used at runtime.
RUN python -m pip uninstall -y pip

RUN useradd -r -u 1000 appuser
USER appuser

CMD ["python", "job.py"]
