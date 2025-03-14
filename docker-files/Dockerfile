# ------------------------------------------ #
# ------ Stage 1: Build dependencies ------ #
# ------------------------------------------ #
FROM python:3.9-slim AS builder

WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# ------------------------------------------ #
# ------ Stage 2: Runtime environment ------ #
# ------------------------------------------ #

FROM python:3.9-slim

WORKDIR /app

# Copy built wheels from builder stage
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Install dependencies
RUN pip install --no-cache /wheels/*

# Copy application code
COPY app.py .
COPY templates templates/

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP app.py
ENV FLASK_ENV production

# Set AWS credentials as environment variables
# These will be overridden by the docker run command
ENV AWS_ACCESS_KEY_ID="mock_key"
ENV AWS_SECRET_ACCESS_KEY="mock_secret"
ENV AWS_REGION="us-east-1"

# Expose the application port
EXPOSE 5001

# Run the application
CMD ["python", "app.py"]