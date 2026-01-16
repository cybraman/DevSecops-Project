FROM python:3.11.8-alpine

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Install dependencies first (better caching)
COPY app/requirements.txt .

RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip uninstall -y jaraco.context || true \
    && python -m pip install --no-cache-dir "jaraco.context==6.1.0" \
    && python -m pip show jaraco.context

# Copy application code
COPY app/ .

ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=5000

USER appuser

EXPOSE 5000

CMD ["python", "main.py"]
