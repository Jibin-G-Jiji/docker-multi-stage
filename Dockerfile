FROM python:3.12-slim AS builder
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*
RUN python -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:$PATH"
COPY requirement.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirement.txt
COPY . .

# Runtime Stage
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv \
    PATH="/opt/venv/bin:$PATH"
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app
EXPOSE 8000
CMD ["/opt/venv/bin/gunicorn", "--bind", "0.0.0.0:8000", "test_django_pro.wsgi:application"]
