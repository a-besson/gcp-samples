FROM python:3.13-slim

ENV PYTHONUNBUFFERED=True \
    PORT=8080

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY service.py .

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "service:app"]
