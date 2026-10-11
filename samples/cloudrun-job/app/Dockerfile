FROM python:3.13-slim@sha256:70729b46c69b4f1e97c4822c1af3df53a1476cf5ddc6c087c0c10bc3a5678c2f

ENV PYTHONUNBUFFERED=True

WORKDIR /app

COPY job.py .

# job.py is stdlib-only: drop pip, whose vendored msgpack/setuptools/urllib3
# carry open HIGH CVEs (Trivy) and are never used at runtime.
RUN python -m pip uninstall -y pip

RUN useradd -r -u 1000 appuser
USER appuser

CMD ["python", "job.py"]
