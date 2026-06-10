FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv

WORKDIR /app

# Install build dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv ${VENV_PATH}

ENV PATH="${VENV_PATH}/bin:$PATH"

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Optional: collect static files during build
# RUN python manage.py collectstatic --noinput

# =========================
# Runtime Stage
# =========================
FROM gcr.io/distroless/python3-debian12

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy virtualenv
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY --from=builder /app /app

EXPOSE 8000

# Distroless images do not have a shell
CMD ["/opt/venv/bin/gunicorn", "--bind", "0.0.0.0:8000", "myproject.wsgi:application"]