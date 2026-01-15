FROM python:3.11-slim-bookworm

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Install dependencies first (better caching)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && pip install --no-cache-dir --upgrade "jaraco.context>=6.1.0"

# Copy application code
COPY app/ .

# Environment variables for Flask (Semgrep-safe)
ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=5000

# Switch to non-root user
USER appuser

EXPOSE 5000

CMD ["python", "main.py"]
