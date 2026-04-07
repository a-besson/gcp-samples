FROM python:3.13-slim

# APP_MODE: "service" (default) starts the Flask web server
#           "job" starts the batch processing script
ARG APP_MODE=service

ENV PYTHONUNBUFFERED=True \
    PORT=8080 \
    APP_MODE=${APP_MODE}

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY service.py .
COPY job.py .

CMD ["sh", "-c", "python ${APP_MODE}.py"]
