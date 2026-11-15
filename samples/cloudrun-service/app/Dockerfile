# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.12-slim@sha256:5e2bdb1b0d542d5039cffb8181c65930093949194a65c365dfb1b0fe13a4fa5b

# python:3.12-slim moved its base OS from Debian 12 (bookworm) to Debian 13
# (trixie) on 2026-11-08 (same tag, new digest) — this pin's zlib1g build
# (1:1.3.dfsg+really1.3.1-1+b1) predates the +deb13u1 security update fixing
# CVE-2026-76844/CVE-2026-85091 (Trivy HIGH). Unpinned on purpose, the base
# digest above stays the anchor — see cloudrun-bastion/app/Dockerfile for the
# same pattern.
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN pip install --no-cache-dir -r requirements.txt

RUN useradd -r -u 1000 appuser && chown -R appuser $APP_HOME
USER appuser

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
