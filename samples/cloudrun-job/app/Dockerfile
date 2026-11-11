FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

ENV PYTHONUNBUFFERED=True

WORKDIR /app

COPY job.py .

# job.py is stdlib-only: drop pip, whose vendored msgpack/setuptools/urllib3
# carry open HIGH CVEs (Trivy) and are never used at runtime.
RUN python -m pip uninstall -y pip

RUN useradd -r -u 1000 appuser
USER appuser

CMD ["python", "job.py"]
