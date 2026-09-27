FROM python:3.13-slim

ENV PYTHONUNBUFFERED=True

WORKDIR /app

COPY job.py .

RUN useradd -r -u 1000 appuser
USER appuser

CMD ["python", "job.py"]
