FROM python:3.10-slim

WORKDIR /app

# Install minimal system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libmagic1 \
    file \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p data/uploads data/vector_store data/backups logs

# Set environment variables
ENV HOST=0.0.0.0
ENV PORT=7860
ENV OLLAMA_ENABLED=false
ENV PYTHONUNBUFFERED=1

# Expose port for HF Spaces
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:7860/api/health', timeout=5)"

# Start application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860", "--timeout-keep-alive", "120"]