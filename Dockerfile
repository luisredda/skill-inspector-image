FROM python:3.12-slim

# Set working directory
WORKDIR /skillspector

# Copy Skillspector source code (from build context)
# Note: Your Harness pipeline should copy this Dockerfile to /skillspector/
# and set the build context to /skillspector/
COPY . .

# Build and install Skillspector
RUN pip install --no-cache-dir -e .

# Create output directory for SARIF results
RUN mkdir -p /output

# Set environment variables with defaults
ENV SCAN_PATH=/workspace \
    OUTPUT_PATH=/output/results.sarif \
    SKILLSPECTOR_LOG_LEVEL=INFO

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
