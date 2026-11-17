FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UPLOAD_ROOT=/tmp/pq-report-uploads \
    SESSION_TTL_HOURS=12 \
    PORT=8080

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py generate_report.py ./

RUN mkdir -p /tmp/pq-report-uploads

EXPOSE 8080

CMD ["sh", "-c", "gunicorn --workers 2 --threads 2 --timeout 180 --graceful-timeout 30 --bind 0.0.0.0:${PORT:-8080} app:app"]
